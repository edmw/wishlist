import Domain

import Vapor
import Fluent

extension InvitationController {

    // MARK: Save

    final class InvitationSaveOutcome: Outcome<UserRepresentation, InvitationEditingContext> {}

    /// Saves an invitation for the specified user from the request’s data.
    /// Validates the data contained in the request, checks the constraints required for a new
    /// invitation and creates a new invitation.
    ///
    /// This function handles thrown `EntityError`s by constructing a page context while adding
    /// the corresponding error flags.
    func save(
        from request: Request,
        for userid: UserID
    ) throws
        -> EventLoopFuture<InvitationSaveOutcome>
    {
        let userInvitationsActor = self.userInvitationsActor
        return try request.content
            .decode(InvitationEditingData.self)
            .flatMap { data in
                let values = InvitationValues(from: data)

                return try userInvitationsActor
                    .createInvitation(
                        .specification(
                            userBy: userid,
                            from: values,
                            sendEmail: data.inputSendEmail ?? false
                        ),
                        .boundaries(
                            worker: request.eventLoop,
                            emailSending: VaporEmailSendingProvider(on: request)
                        )
                    )
                    .map { result in
                        let user = result.user
                        let context = InvitationEditingContext(with: data)
                        return .success(with: user, context: context)
                    }
                    .catchMap(UserInvitationsActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, data: data)
                    }
            }
    }

    private func handleErrorOnSave(
        with error: UserInvitationsActorError,
        data: InvitationEditingData
    ) throws
        -> InvitationSaveOutcome
    {
        if case let UserInvitationsActorError
            .validationError(user, _, error) = error
        {
            var context = InvitationEditingContext(with: data)
            switch error {
            case .validationFailed(let properties, _):
                context.invalidEmail = properties.contains(\InvitationValues.email)
            default:
                throw error
            }
            return .failure(with: user, context: context, has: error)
        }
        else {
            throw error
        }
    }

}
