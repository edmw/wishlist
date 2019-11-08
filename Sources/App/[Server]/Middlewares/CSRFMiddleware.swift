import Vapor

/// Middleware to prevent Cross-Site Request Forgery by verifying origin with standard headers.
/// @see https://seclab.stanford.edu/websec/csrf/csrf.pdf (Section 5)
///
/// All state-modifying requests, including login requests, must be sent using the POST method.
/// In particular, state-modifying GET requests must be blocked in order to address the forum
/// poster threat model. If the Origin header is present, the server must reject any requests
/// whose Origin header contains an undesired value (including null).
final class CSRFMiddleware: Middleware, ServiceType {

    struct Configuration {

        /// Default CSRF configuration.
        public static func `default`() -> Configuration {
            return .init(
                targetOrigin: "http://localhost"
            )
        }

        public let targetOrigin: String

        public init(
            targetOrigin: String
        ) {
            self.targetOrigin = targetOrigin.lowercased()
        }

    }

    let configuration: Configuration

    init(configuration: Configuration = .default()) {
        self.configuration = configuration
    }

    func respond(
        to request: Request,
        chainingTo next: Responder
    ) throws -> EventLoopFuture<Response> {
        guard let origin = request.http.headers[.origin].first else {
            // Origin header not present (we rely on the browser’s correct origin header handling)
            return try next.respond(to: request)
        }
        // If the origin header is present, we reject any non-get requests whose origin header
        // contains an undesired value (including null).
        guard request.http.method == .GET || origin.lowercased() == configuration.targetOrigin
            else {
                request.requireLogger().warning(
                    "[CRSF] Abort request because origin header '\(origin)'" +
                        " does not match target origin '\(configuration.targetOrigin)'."
                )
                throw Abort(.badRequest)
        }
        return try next.respond(to: request)
    }

    // MARK: ServiceType {

    static var serviceSupports: [Any.Type] {
        return [CSRFMiddleware.self]
    }

    static func makeService(for container: Container) throws
        -> CSRFMiddleware
    {
        return .init()
    }

}
