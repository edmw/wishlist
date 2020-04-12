import Domain

import Vapor

// MARK: ProfileController

final class ProfileController: AuthenticatableController,
    RouteCollection
{
    let userProfileActor: UserProfileActor

    init(_ userProfileActor: UserProfileActor) {
        self.userProfileActor = userProfileActor
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try userProfileActor
            .getProfileAndInvitations(
                .specification(userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .profileAndInvitations(with: result), on: request)
            }
    }

    /// Renders a form view for creating or updating the profile.
    /// This is only accessible for an authenticated user.
    private func renderFormView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let userid = try requireAuthenticatedUserID(on: request)

        return try userProfileActor
            .requestProfileEditing(
                .specification(userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .profileEditing(with: result), on: request)
            }
   }

    // MARK: - CRUD

    private func update(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try save(from: request, for: userid)
            .caseSuccess { user in
                self.success(for: user, on: request)
            }
            .caseFailure { user, context in
                try self.failure(for: user, with: context, on: request)
            }
    }

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(for user: UserRepresentation, on request: Request)
        -> EventLoopFuture<Response>
    {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(for: user.id, to: "", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private func failure(
        for user: UserRepresentation,
        with editingContext: ProfileEditingContext,
        on request: Request
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.render(
            page: .profileEditing(with: user, editingContext: editingContext),
            on: request
        )
        .encode(for: request)
    }

    // MARK: - Routing

    private func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PUT:
                    return try self.update(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // profile displaying

        router.get("user", ID.parameter, use: self.renderView)

        // profile handling

        router.get("user", ID.parameter, "edit",
            use: self.renderFormView
        )
        router.post("user", ID.parameter,
            use: self.dispatch
        )
    }

}
