import Domain

import Vapor
import Fluent

extension InvitationController {

    // MARK: Save

    struct InvitationSaveResult {
        let user: UserRepresentation
        let invitation: InvitationRepresentation
    }
    final class InvitationSaveOutcome: Outcome<InvitationSaveResult, InvitationPageContext> {}

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
            .decode(InvitationPageFormData.self)
            .flatMap { formdata in
                let values = InvitationValues(from: formdata)

                var contextBuilder = InvitationPageContextBuilder().withFormData(formdata)

                return try userInvitationsActor
                    .createInvitation(
                        .specification(
                            userBy: userid,
                            from: values,
                            sendEmail: formdata.inputSendEmail ?? false
                        ),
                        .boundaries(
                            worker: request.eventLoop,
                            emailSending: VaporEmailSendingProvider(on: request)
                        )
                    )
                    .map { result in
                        return try self.handleSuccessOnSave(result, contextBuilder: contextBuilder)
                    }
                    .catchMap(UserInvitationsActorError.self) { error in
                        if case let UserInvitationsActorError
                            .validationError(user, invitation, error) = error
                        {
                            contextBuilder = contextBuilder.with(user, invitation)
                            return try self.handleErrorOnSave(error, with: contextBuilder.build())
                        }
                        throw error
                    }
            }
    }

    private func handleSuccessOnSave(
        _ result: CreateInvitation.Result,
        contextBuilder: InvitationPageContextBuilder
    ) throws -> InvitationSaveOutcome {
        let context = try contextBuilder.forUserRepresentation(result.user).build()
        return .success(
            with: .init(user: result.user, invitation: result.invitation),
            context: context
        )
    }

    private func handleErrorOnSave(
        _ error: ValuesError<InvitationValues>,
        with contextIn: InvitationPageContext
    ) throws
        -> InvitationSaveOutcome
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.invalidEmail = properties.contains(\InvitationValues.email)
        default:
            throw error
        }
        return .failure(with: error, context: context)
    }

}
