import Domain

import Vapor
import Imperial

// MARK: NetIDAuthenticatorController

final class NetIDAuthenticatorController: AuthenticationController, RouteCollection {

    let successPath: String
    let errorPath: String

    init(
        _ enrollmentActor: EnrollmentActor,
        authenticationSuccessPath: String,
        authenticationErrorPath: String
    ) {
        self.successPath = authenticationSuccessPath
        self.errorPath = authenticationErrorPath
        super.init(enrollmentActor)
    }

    /// Signs in a netID user identifiable by the given access token.
    ///
    /// After successfully gathering the user‘s information from netID, authenticates the subject
    /// and creates or update the user‘s entity. Attaches the user‘s entity to the current session
    /// and redirects to our Start page.
    ///
    /// - Parameters:
    ///   - request: Request context
    ///   - token: Access token for netID‘s UserInfo API
    /// - Returns: Redirect to Start page
    ///
    func signin(_ request: Request, _ token: String) throws
        -> EventLoopFuture<ResponseEncodable>
    {
        var userInfoURLComponents = URLComponents()
        userInfoURLComponents.scheme = "https"
        userInfoURLComponents.host = "broker.netid.de"
        userInfoURLComponents.path = "/userinfo"

        guard let userInfoURLComponentsURL = userInfoURLComponents.url else {
            throw Abort(.internalServerError,
                reason: "Error while building netID UserInfo URL"
            )
        }

        var userInfoHttpRequest = HTTPRequest(method: .GET, url: userInfoURLComponentsURL)
        userInfoHttpRequest.headers.bearerAuthorization = BearerAuthorization(token: token)

        let userInfoRequest = Request(http: userInfoHttpRequest, using: request)

        // perform http request to get userinfo from google
        return try request
            .client()
            .send(userInfoRequest)
            .flatMap { response -> EventLoopFuture<NetIDAuthenticationUserInfo> in
                // decode user info from request data
                try response.content.decode(NetIDAuthenticationUserInfo.self)
            }
            .flatMap { userInfo in
                // authenticate user and redirect
                return try self.authenticate(
                    using: userInfo,
                    redirect: self.successPath,
                    on: request
                )
            }
            .catchMap { error in
                return try self.redirectFailedLogin(with: error, to: self.errorPath, on: request)
            }
    }

    func boot(router: Router) throws {
        let siteURL = try Environment.requireSiteURL()
        let config = NetIDConfig(
            authenticate: "netid/authenticate",
            callback: "\(siteURL)/netid/authenticate-callback",
            claims: ["given_name", "family_name", "email"],
            state: { request in
                guard let state = try request.createState() else {
                    throw Abort(.internalServerError)
                }
                return state
            },
            stateVerify: { request, state in request.verifyState(state) }
        )
        try Imperial.NetID(router: router, config: config, completion: signin)
    }

}
