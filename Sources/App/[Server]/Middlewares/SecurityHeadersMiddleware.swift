import Vapor

final class SecurityHeadersMiddleware: Middleware, ServiceType {

    var configurations: [SecurityHeadersConfiguration]

    init(environment: Environment) {
        self.configurations = [
            ContentSecurityPolicyConfiguration(value: "default-src 'self'"),
            ContentTypeOptionsConfiguration(.nosniff),
            ReferrerPolicyConfiguration(.sameOrigin),
            FrameOptionsConfiguration(.deny)
        ]
    }

    func respond(
        to request: Request, chainingTo next: Responder
    ) throws -> EventLoopFuture<Response> {
        let response = try next.respond(to: request)

        return response.map(to: Response.self) { response in
            for configuration in self.configurations {
                configuration.setHeader(on: response, from: request)
            }
            return response
        }
    }

    // MARK: ServiceType

    static var serviceSupports: [Any.Type] {
        return [SecurityHeadersMiddleware.self]
    }

    static func makeService(for container: Container) throws
        -> SecurityHeadersMiddleware
    {
        return .init(environment: container.environment)
    }

}

extension HTTPHeaderName {

    static let xContentTypeOptions = HTTPHeaderName("X-Content-Type-Options")

}
