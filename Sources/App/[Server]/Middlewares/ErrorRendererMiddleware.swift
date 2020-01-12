import Vapor
import Library

final class ErrorRendererMiddleware: Middleware, ServiceType {

    let template401: String
    let template404: String
    let templateServer: String

    // Context for view rendering
    fileprivate let context: [String: AnyEncodable]

    init(
        template401: String,
        template404: String,
        templateServer: String,
        context: [String: Encodable]?
    ) {
        self.template401 = template401
        self.template404 = template404
        self.templateServer = templateServer

        // Note: encoding strategies won't work after transforming the values to `AnyEncodable`.
        self.context = context?.mapValues { AnyEncodable($0) } ?? [:]
    }

    func respond(
        to request: Request,
        chainingTo next: Responder
    ) throws -> EventLoopFuture<Response> {
        let response: EventLoopFuture<Response>
        do {
            // get response from next responder
            response = try next.respond(to: request)
        }
        catch {
            // responder did throw an error (this does not include failed responses)
            request.requireLogger().error(
                "Error while processing request: \(error), path: \(request.http.url)"
            )
            return try self.renderError(for: request, status: HTTPStatus(for: error))
        }
        return response
            .flatMap { response -> EventLoopFuture<Response> in
                // handle response
                // if status code indicates an error render it
                guard response.http.status.code < HTTPResponseStatus.badRequest.code else {
                    return try self.renderError(for: request, status: response.http.status)
                }
                return try response.encode(for: request)
            }
            .catchFlatMap { error -> EventLoopFuture<Response> in
                // handle failed response
                request.requireLogger().error(
                    "Error while processing request: \(error), path: \(request.http.url)"
                )
                return try self.renderError(for: request, status: HTTPStatus(for: error))
            }
    }

    private func renderError(
        for request: Request,
        status: HTTPStatus
    ) throws -> EventLoopFuture<Response> {
        request.requireLogger().info(
            "Render error page for status: \(status.code), path: \(request.http.url)"
        )
        let renderer = try request.make(ViewRenderer.self)
        return try renderErrorPage(for: request, with: status, on: renderer)
    }

    private func renderErrorPage(
        for request: Request,
        with status: HTTPStatus,
        on renderer: ViewRenderer
    ) throws -> EventLoopFuture<Response> {
        let logger = request.requireLogger()

        if status == .notFound {
            return try renderer
                .render(template404, context, request: request, status: status)
                .encode(for: request)
                .map(to: Response.self) { response in
                    response.http.status = status
                    return response
                }
                .catchFlatMap { error -> EventLoopFuture<Response> in
                    logger.error("Failed to render 404 error page - \(error)")
                    return try self.renderServerErrorPage(
                        for: request, with: status, on: renderer
                    )
                }
        }
        else if status == .unauthorized {
            return try renderer
                .render(template401, context, request: request, status: status)
                .encode(for: request)
                .map(to: Response.self) { response in
                    response.http.status = status
                    return response
                }
                .catchFlatMap { error -> EventLoopFuture<Response> in
                    logger.error("Failed to render 401 error page - \(error)")
                    return try self.renderServerErrorPage(
                        for: request, with: status, on: renderer
                    )
                }
        }
        return try renderServerErrorPage(
            for: request, with: status, on: renderer
        )
    }

    private func renderServerErrorPage(
        for request: Request,
        with status: HTTPStatus,
        on renderer: ViewRenderer
    ) throws -> EventLoopFuture<Response> {
        let logger = request.requireLogger()

        return try renderer
            .render(templateServer, context, request: request, status: status)
            .encode(for: request)
            .map(to: Response.self) { response in
                response.http.status = status
                return response
            }
            .catchFlatMap { error -> EventLoopFuture<Response> in
                logger.error("Failed to render server error page - \(error)")

                let body = "<h1>Internal Error</h1><p>There was an internal error." +
                    " Please try again later.</p>"

                return try body
                    .encode(for: request)
                    .map(to: Response.self) { response in
                        response.http.status = status
                        response.http.headers.replaceOrAdd(
                            name: .contentType,
                            value: "text/html; charset=utf-8"
                        )
                        return response
                    }
            }
    }

    // MARK: ServiceType

    static var serviceSupports: [Any.Type] {
        return [ErrorRendererMiddleware.self]
    }

    static func makeService(for container: Container) throws
        -> ErrorRendererMiddleware
    {
        return .init(
            template401: "401",
            template404: "404",
            templateServer: "Server",
            context: nil
        )
    }

}

// MARK: -

extension ViewRenderer {

    fileprivate func render(
        _ template: String,
        _ context: [String: AnyEncodable],
        request: Request,
        status: HTTPStatus
    ) -> EventLoopFuture<View> {
        return render(template, context.updating([
            "error": "\(status.code)",
            "status": status.code.description,
            "statusMessage": status.reasonPhrase,
            "path": String(describing: request.http.url)
        ]))
    }

}

// MARK: -

extension HTTPStatus {

    internal init(for error: Error) {
        if let abort = error as? AbortError {
            self = abort.status
        }
        else {
            self = .internalServerError
        }
    }

}

// MARK: -

extension Dictionary where Key == String, Value == AnyEncodable {

    fileprivate func updating(_ other: [String: String]) -> [String: AnyEncodable] {
        return merging(other.mapValues { AnyEncodable($0) }) { _, new in new }
    }

}
