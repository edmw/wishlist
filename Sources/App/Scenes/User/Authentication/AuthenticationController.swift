import Vapor

import Foundation

class AuthenticationController: ProtectedController {

    /// Authenticates the user described by the given user info and returns a redirect on success.
    static func authenticate(
        using userInfo: AuthenticationUserInfo,
        redirect defaultLocation: String,
        on request: Request
    ) throws -> EventLoopFuture<ResponseEncodable> {

        // check authentication state
        // state token in session must match state token transported in query

        guard let authenticationState = try getState(on: request) else {
            throw Abort(.badRequest,
                reason: "Error while decoding state parameter in request."
            )
        }
        guard let authenticationToken = try request.session().getAuthenticationToken() else {
            throw Abort(.forbidden,
                reason: "Authentication aborted: No authentication token in session"
            )
        }
        guard authenticationState.token == authenticationToken else {
            throw AuthenticationError.invalidToken
        }

        let siteAccess = try request.site().access

        // check site access

        guard [.all, .invited, .existing].contains(siteAccess) else {
            throw AuthenticationError.siteLocked
        }

        // authenticate user with user info
        return try request.authenticate(
            using: userInfo,
            state: authenticationState,
            access: siteAccess
        )
        .map { user in
            // redirect to location (now with session and user)
            let location: String
            if let locator = authenticationState.locator, locator.isLocal {
                location = locator.stringValue
            }
            else {
                location = defaultLocation
            }
            return try AuthenticationController
                .redirectSucceededLogin(for: user, to: location, on: request)
        }
    }

    static func createState(on request: Request) throws -> String? {
        // create an authentication state
        var authenticationState = try AuthenticationState()
        authenticationState.locator = request.query.getLocator()
        authenticationState.invitationCode = request.query[.invitationCode]
        // encode authentication state to string
        let encoder = try request.make(ContentCoders.self).requireDataEncoder(for: .json)
        let stateData = try encoder.encode(authenticationState)
        let stateString = String(data: stateData, encoding: .utf8)
        // put associated token into session
        try request.session().set(authenticationToken: authenticationState.token)

        return stateString
    }

    static func verifyState(_ stateString: String, on request: Request) throws -> Bool {
        guard let stateData = stateString.data(using: .utf8) else {
            return false
        }

        let decoder = try request.make(ContentCoders.self).requireDataDecoder(for: .json)
        let authenticationState = try decoder.decode(AuthenticationState.self, from: stateData)

        guard let authenticationToken = try request.session().getAuthenticationToken() else {
            return false
        }
        guard authenticationState.token == authenticationToken else {
            return false
        }
        return true
    }

    private static func getState(on request: Request) throws -> AuthenticationState? {
        // get state string from request query
        let stateString = try request.query.get(String.self, at: "state")
        guard let stateData = stateString.data(using: .utf8) else {
            return nil
        }
        // decode authentication state from string
        let decoder = try request.make(ContentCoders.self).requireDataDecoder(for: .json)
        let authenticationState = try decoder.decode(AuthenticationState.self, from: stateData)

        return authenticationState
    }

    /// Returns a redirect response to the specified location for the specified user
    /// after a succeeded login.
    static func redirectSucceededLogin(
        for user: User,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) throws -> Response {
        var parameters = [ControllerParameter]()

        if user.firstLogin == user.lastLogin {
            // add flag to query if this is the first login of the given user
            parameters.append(.welcome())
        }

        return redirect(to: location, parameters: parameters, type: type, on: request)
    }

    /// Returns a redirect response to the specified location
    /// after a failed login with an error.
    static func redirectFailedLogin(
        with error: Error,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) throws -> Response {
        request.logger?.application.info(
            "Autentication failed with error \(error)"
        )
        return request.redirect(to: location, type: type)
    }

}

extension LocatorKeys {
    static let loginSuccess = LocatorKey("loginSuccess")
}
