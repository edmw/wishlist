import Domain

import Vapor

import Foundation

// MARK: AuthenticationController

class AuthenticationController: AuthenticatableController {

    let enrollmentActor: EnrollmentActor

    init(_ enrollmentActor: EnrollmentActor) {
        self.enrollmentActor = enrollmentActor
    }

    /// Returns checked authentication state. Throws if invalid.
    ///
    /// State token in session must match state token transported in request query
    private func requireAuthenticationState(on request: Request) throws -> AuthenticationState {
        guard let authenticationState = try request.getAuthenticationStateFromQuery() else {
            throw Abort(.badRequest,
                reason: "Error while decoding state parameter in request."
            )
        }
        guard let authenticationToken = try request.getAuthenticationTokenFromSession() else {
            throw Abort(.forbidden,
                reason: "Authentication aborted: No authentication token in session"
            )
        }
        guard authenticationState.token == authenticationToken else {
            throw AuthenticationError.invalidToken
        }
        return authenticationState
    }

    /// Authenticates the user described by the given user info and returns a redirect on success.
    func authenticate(
        using userInfo: AuthenticationUserInfo,
        redirect defaultLocation: String,
        on request: Request
    ) throws -> EventLoopFuture<ResponseEncodable> {
        let siteAccess = try request.site().access

        // check authentication state
        let authenticationState = try requireAuthenticationState(on: request)

        // get identification
        let guestIdentification = try request.requireIdentification()

        // delete current session to avoid session fixation
        try request.destroySession()

        // materialise user with given user info and authentication state
        return try enrollmentActor.materialiseUser(
            .specification(
                options: .init(from: siteAccess),
                userIdentity: .init(from: userInfo),
                userIdentityProvider: .init(from: userInfo),
                userValues: .init(from: userInfo),
                invitationCode: authenticationState.invitationCode,
                guestIdentification: guestIdentification
            ),
            .boundaries(worker: request.eventLoop)
        )
        .map { result in
            let userid = result.userID
            let user = result.user
            let identification = result.identification

            // attach userid to session
            try request.authenticateSession(userid)
            // set identification
            try request.setIdentificationForSession(identification)

            // initialize session with data from user (e.g. language)
            try request.session().initialize(with: user)

            // redirect to location (now with session and user)
            let location: String
            if let locator = authenticationState.locator, locator.isLocal {
                location = locator.stringValue
            }
            else {
                location = defaultLocation
            }
            return try self.redirectSucceededLogin(for: result.user, to: location, on: request)
        }
    }

    /// Returns a redirect response to the specified location for the specified user
    /// after a succeeded login.
    func redirectSucceededLogin(
        for user: UserRepresentation,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) throws -> Response {
        var parameters = [ControllerParameter]()

        if user.firstLogin == user.lastLogin {
            // add flag to query if this is the first login of the given user
            parameters.append(.welcome())
        }

        return Controller.redirect(to: location, parameters: parameters, type: type, on: request)
    }

    /// Returns a redirect response to the specified location
    /// after a failed login with an error.
    func redirectFailedLogin(
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

extension MaterialiseUser.Options {

    /// Creates a valid option set for user materialisation according to the specified site access.
    init(from access: SiteAccess) throws {
        switch access {
        case .all:
            self = [.createUsers]
        case .invited:
            self = [.createUsers, .requireInvitationToCreateUsers]
        case .existing:
            self = []
        case .nobody:
            throw AuthenticationError.siteLocked
        }
    }

}

extension Logger {

    fileprivate func siteLocked(_ email: String) {
        self.warning(
            "Authentication for user with email \(email) denied: Site is locked"
        )
    }

}
