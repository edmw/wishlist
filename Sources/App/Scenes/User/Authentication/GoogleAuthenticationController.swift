import Vapor
import Imperial
import FluentSQLite

final class GoogleAuthenticatorController: AuthenticationController, RouteCollection {

    var google: Imperial.Google?

    let successPath: String
    let errorPath: String

    let logger: Logger?

    init(
        authenticationSuccessPath: String,
        authenticationErrorPath: String,
        logger: Logger? = nil
    ) {
        self.successPath = authenticationSuccessPath
        self.errorPath = authenticationErrorPath

        self.logger = logger
    }

    /// Signs in a Google user identifiable by the given access token.
    ///
    /// After sucessfully gathering the user‘s information from Google, authenticates the subject
    /// and creates or update the user‘s entity. Attaches the user‘s entity to the current session
    /// and redirects to our Start page.
    ///
    /// - Parameters:
    ///   - request: Request context
    ///   - token: Access token for Google‘s UserInfo API
    /// - Returns: Redirect to Start page
    ///
    func signin(_ request: Request, _ token: String) throws
        -> EventLoopFuture<ResponseEncodable>
    {
        var userInfoURLComponents = URLComponents()
        userInfoURLComponents.scheme = "https"
        userInfoURLComponents.host = "www.googleapis.com"
        userInfoURLComponents.path = "/oauth2/v2/userinfo"

        guard let userInfoURLComponentsURL = userInfoURLComponents.url else {
            throw Abort(.internalServerError,
                reason: "Error while building Google UserInfo URL"
            )
        }

        var userInfoHttpRequest = HTTPRequest(method: .GET, url: userInfoURLComponentsURL)
        userInfoHttpRequest.headers.bearerAuthorization = BearerAuthorization(token: token)

        let userInfoRequest = Request(http: userInfoHttpRequest, using: request)

        // perform http request to get userinfo from google
        return try request
            .client()
            .send(userInfoRequest)
            .flatMap { response -> Future<GoogleAuthenticationUserInfo> in
                // decode user info from request data
                try response.content.decode(GoogleAuthenticationUserInfo.self)
            }
            .flatMap { userInfo in
                // authenticate user and redirect
                return try AuthenticationController
                    .authenticate(using: userInfo, redirect: self.successPath, on: request)
            }
            .catchMap { error in
                return try AuthenticationController
                    .redirectFailedLogin(with: error, to: self.errorPath, on: request)
            }
    }

    func authenticate(on request: Request) throws -> Future<Response> {
        guard let googleRouterAuthenticationURL = try google?.router.authURL(request) else {
            throw Abort(.internalServerError)
        }

        guard let googleAuthenticationURL = URL(string: googleRouterAuthenticationURL) else {
            throw Abort(.internalServerError)
        }

        // create authentication state encoded as string
        guard let authenticationState = try AuthenticationController.createState(on: request) else {
            throw Abort(.internalServerError)
        }

        // append authentication state to google authentication url
        let queryState = URLQueryItem(name: "state", value: authenticationState)

        guard let url = googleAuthenticationURL.urlByAppendingQueryItem(queryState) else {
            throw Abort(.internalServerError)
        }
        let redirect: Response = request.redirect(to: url.absoluteString)
        return request.eventLoop.newSucceededFuture(result: redirect)
    }

    func boot(router: Router) throws {
        let siteURL = try Environment.requireSiteURL()
        let authenticateRoute = "google/authenticate"
        let callbackRoute = "google/authenticate-callback"
        let callback = "\(siteURL)/\(callbackRoute)"
        google = try Imperial.Google(
            router: router,
            authenticate: authenticateRoute,
            authenticateCallback: nil,
            callback: callback,
            scope: ["profile", "email", "openid"],
            completion: signin
        )
        router.get(authenticateRoute, use: authenticate)
    }

}
