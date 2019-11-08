import Vapor
import Random

// MARK: - Controller Parameters

extension ControllerParameterKeys {
    static let invitationCode = ControllerParameterKey<InvitationCode>("invitation")
}

// MARK: - Controller

final class LoginController: Controller, RouteCollection {

    /// Login page:
    /// Accepts a parameter `invitation` (InvitationCode) which enables sign up for invitees.
    /// Accepts a parameter `p` (Locator) which will be used for redirect after login succeeds.
    static func renderView(on request: Request) throws -> EventLoopFuture<View> {
        var authenticationParameters = [ControllerParameter]()

        if let locator = request.query.getLocator() {
            authenticationParameters.append(
                ControllerParameter(key: .locator, locator)
            )
        }

        let invitationCode = request.query[.invitationCode]
        if let invitationCode = invitationCode {
            authenticationParameters.append(
                ControllerParameter(key: .invitationCode, invitationCode)
            )
        }

        let context = try LoginPageContext(
            authenticationParametersQuery: buildQuery(parameters: authenticationParameters),
            invitationCode: invitationCode
        )
        return try renderView("Public/Login", with: context, on: request)
    }

    func boot(router: Router) throws {
        router.get("signin") { request -> EventLoopFuture<Response> in
            guard try request.isAuthenticated(User.self) == false else {
                return LoginController.redirect(to: "/", on: request)
            }
            return try LoginController.renderView(on: request)
                .flatMap { view in
                    return try view.encode(for: request)
                }
        }
    }

}

// MARK: -

extension InvitationCode: ControllerParameterValue {

    var stringValue: String {
        return rawValue
    }

}
