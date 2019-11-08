import Vapor
import Fluent

extension InvitationController {

    // MARK: Save

    struct SaveResult {
        let invitation: Invitation
        let thenSendEmail: Bool
    }

    struct SaveError: Error {
        let context: InvitationPageContext
    }

    /// Saves an invitation for the specified user from the request’s data.
    /// Validates the data contained in the request, checks the constraints required for a new
    /// invitation and creates a new invitation.
    ///
    /// This function handles thrown `EntityError`s by rendering the form page again while adding
    /// the corresponding error flags to the page context.
    static func save(
        from request: Request,
        for user: User
    ) throws
        -> EventLoopFuture<Result<SaveResult, SaveError>>
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
                            let thenSendEmail = formdata.inputSendEmail ?? false
                            return .success(
                                SaveResult(invitation: invitation, thenSendEmail: thenSendEmail)
                            )
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
        -> Result<SaveResult, SaveError>
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.invalidEmail = properties.contains(\Invitation.email)
        default:
            throw error
        }
        return .failure(SaveError(context: context))
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

// MARK: Future

// Note: this is a big "playground". The goal is to make these extensions generic in way they can
// handle abritrary save results. If this is not gonna happen, it would be much simpler to revert
// this to the previous solution as used in the other Save controllers.

struct CaseSuccessError: Error {
    let context: InvitationPageContext
}

extension EventLoopFuture
    where Expectation == Result<InvitationController.SaveResult, InvitationController.SaveError> {

    func caseSuccess(
        _ callback: @escaping (Invitation, Bool) throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Result<EventLoopFuture<Response>, CaseSuccessError>> {
        return self.map { result in
            switch result {
            case let .success(saveResult):
                return try .success(callback(saveResult.invitation, saveResult.thenSendEmail))
            case let .failure(saveError):
                return .failure(CaseSuccessError(context: saveError.context))
            }
        }
    }

}

extension EventLoopFuture where Expectation == Result<EventLoopFuture<Response>, CaseSuccessError> {

    func caseFailure (
        _ callback: @escaping (InvitationPageContext) throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Response> {

        return self.flatMap { result in
            switch result {
            case let .success(success):
                return success
            case let .failure(error):
                return try callback(error.context)
            }
        }
    }

}
