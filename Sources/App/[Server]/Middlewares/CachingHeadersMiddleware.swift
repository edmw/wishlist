import Vapor

/// Very simple middleware to set nocaching headers.
final class CachingHeadersMiddleware: Middleware, ServiceType {

    func respond(
        to request: Request, chainingTo next: Responder
    ) throws -> Future<Response> {
        let response = try next.respond(to: request)

        return response.map(to: Response.self) { response in
            response.http.headers.replaceOrAdd(
                name: HTTPHeaderName("Cache-Control"),
                value: "no-cache, no-store, must-revalidate"
            )
            return response
        }
    }

    static func noCachingMiddleware() -> CachingHeadersMiddleware {
        return .init()
    }

    // MARK: ServiceType

    static var serviceSupports: [Any.Type] {
        return [CachingHeadersMiddleware.self]
    }

    static func makeService(for container: Container) throws
        -> CachingHeadersMiddleware
    {
        return .init()
    }

}
