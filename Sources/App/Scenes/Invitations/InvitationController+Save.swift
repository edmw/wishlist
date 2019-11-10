import Vapor
import Fluent

extension InvitationController {

    // MARK: Save

    struct InvitationSaveValue {
        let invitation: Invitation
        let thenSendMail: Bool
    }

    final class InvitationSaveOutcome: Outcome<InvitationSaveValue, InvitationPageContext> {}

    /// Saves an invitation for the specified user from the request’s data.
    /// Validates the data contained in the request, checks the constraints required for a new
    /// invitation and creates a new invitation.
    ///
    /// This function handles thrown `EntityError`s by constructing a page context while adding
    /// the corresponding error flags.
    static func save(
        from request: Request,
        for user: User
    ) throws
        -> EventLoopFuture<InvitationSaveOutcome>
    {
        return try request.content
            .decode(InvitationPageFormData.self)
            .flatMap { formdata in
                let context = try InvitationPageContextBuilder()
                    .forUser(user)
                    .withFormData(formdata)
                    .build()

                return request.future()
                    .flatMap {
                        return try save(
                            from: formdata,
                            for: user,
                            on: request
                        )
                        .map { invitation in
                            let value = InvitationSaveValue(
                                invitation: invitation,
                                thenSendMail: formdata.inputSendEmail ?? false
                            )
                            return .success(with: value, context: context)
                        }

                    }
                    .catchMap(EntityError<Invitation>.self) {
                        try handleErrorOnSave($0, with: context)
                    }
            }
    }

    private static func handleErrorOnSave(
        _ error: EntityError<Invitation>,
        with contextIn: InvitationPageContext
    ) throws
        -> InvitationSaveOutcome
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.invalidEmail = properties.contains(\Invitation.email)
        default:
            throw error
        }
        return .failure(with: error, context: context)
    }

    /// Saves an invitation for the specified user from the given form data.
    /// Validates the data, checks the constraints required for a new invitation and creates
    /// a new invitation.
    ///
    /// Throws `EntityError`s for invalid data or violated constraints.
    private static func save(
        from formdata: InvitationPageFormData,
        for user: User,
        on request: Request
    ) throws
        -> EventLoopFuture<Invitation>
    {
        let invitationRepository = try request.make(InvitationRepository.self)

        return try InvitationData(from: formdata)
            .validate(for: user, using: invitationRepository, on: request)
            .flatMap { data in
                let entity: Invitation
                // create invitation
                entity = try Invitation(for: user, from: data)

                return invitationRepository.save(invitation: entity)
            }
    }

}