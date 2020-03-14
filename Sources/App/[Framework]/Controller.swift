import Vapor

import Domain

/// Controller for resources:
/// Defines some common functions to be of use in resources controllers.
class Controller {

    /// Returns the http method of the specified request. If the http method is POST there
    /// will be some speciality: A client can perfom a specific method other than POST
    /// by sending a POST request and including the parameter ´__method´. That way a
    /// web page, for example, can send a DELETE request by using a POST form.
    func method(of request: Request) throws -> EventLoopFuture<HTTPMethod> {
        let method = request.http.method
        if method == .POST {
            return request.content[String.self, at: "__method"]
                .map { methodString in
                    let method: HTTPMethod
                    switch methodString {
                    case .none:
                        method = .POST
                    case .some("GET"):
                        method = .GET
                    case .some("POST"):
                        method = .POST
                    case .some("PUT"):
                        method = .PUT
                    case .some("DELETE"):
                        method = .DELETE
                    case .some("PATCH"):
                        method = .PATCH
                    default:
                        throw Abort(.methodNotAllowed)
                    }
                    return method
                }
        }
        return request.future(method)
    }

    /// Builds a query string from the given parameters.
    static func query(with parameters: [ControllerParameter]) throws -> String? {
        var combinedParameters = [String: String?]()
        parameters.forEach { combinedParameters.merge($0) }
        let encodedParameters = try URLEncodedFormEncoder().encode(combinedParameters)
        return String(data: encodedParameters, encoding: .utf8)
    }

    /// Returns a redirect response to the specified location with the specified parameters
    /// in the query on the given request.
    /// Attention: Because this is an internal function it will fail fatally if there are errors
    /// encoding the given parameters. The caller is responsible to guarantee the validity of
    /// the parameters.
    static func redirect(
        to location: String,
        parameters: [ControllerParameter]? = nil,
        type: RedirectType = .normal,
        on request: Request
    ) -> Response {
        if let parameters = parameters, !parameters.isEmpty {
            do {
                if let queryString = try query(with: parameters) {
                    return request.redirect(to: "\(location)?\(queryString)", type: type)
                }
            }
            catch {
                request.logger?.technical.error(
                    "Unable to make query with parameters "
                    + "\(String(describing: parameters)): \(error)"
                )
            }
            fatalError("Failed to make query with parameters: \(String(describing: parameters))")
        }
        else {
            return request.redirect(to: "\(location)", type: type)
        }
    }

    /// Returns a redirect response as a succeeded future to the specified location with the
    /// specified parameters in the query on the specified request.
    static func redirect(
        to location: String,
        parameters: [ControllerParameter]? = nil,
        type: RedirectType = .normal,
        on request: Request
    ) -> EventLoopFuture<Response> {
        return request.future(redirect(to: location, type: type, on: request))
    }

    /// Returns a redirect response to the specified location for the given user
    /// on the specified request.
    static func redirect(
        for userid: UserID?,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) -> Response {
        guard let id = userid else {
            return request.redirect(to: "/")
        }
        return request.redirect(to: "/user/\(ID(id))/\(location)", type: type)
    }

    /// Returns a redirect response as a succeeded future to the specified location
    /// for the specified user on the specified request.
    static func redirect(
        for userid: UserID,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) -> EventLoopFuture<Response> {
        return request.future(
            redirect(for: userid, to: location, type: type, on: request)
        )
    }

    /// Returns a redirect response to the specified location for the specified user
    /// and list on the specified request.
    static func redirect(
        for userid: UserID?,
        and listid: ListID?,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) -> Response {
        guard let uid = userid else {
            return request.redirect(to: "/")
        }
        guard let lid = listid else {
            return request.redirect(to: "/")
        }
        return request.redirect(to: "/user/\(ID(uid))/list/\(ID(lid))/\(location)", type: type)
    }

    /// Returns a redirect response as a succeeded future to the specified location
    /// for the specified user and list on the specified request.
    static func redirect(
        for userid: UserID,
        and listid: ListID,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) -> EventLoopFuture<Response> {
        return request.future(
            redirect(for: userid, and: listid, to: location, type: type, on: request)
        )
    }

    /// Returns a redirect response to the specified wishlist on the specified request.
    static func redirect(
        for listid: ListID?,
        parameters: [ControllerParameter]? = nil,
        type: RedirectType = .normal,
        on request: Request
    ) -> Response {
        guard let id = listid else {
            return request.redirect(to: "/")
        }
        return redirect(to: "/list/\(ID(id))", parameters: parameters, type: type, on: request)
    }

    /// Returns a redirect response as a succeeded future to the specified wishlist
    /// on the specified request.
    static func redirect(
        for listid: ListID?,
        parameters: [ControllerParameter]? = nil,
        type: RedirectType = .normal,
        on request: Request
    ) -> EventLoopFuture<Response> {
        return request.future(
            redirect(for: listid, parameters: parameters, type: type, on: request)
        )
    }

}

extension Request {

    var queryDictionary: [String: String?] {
        return URLComponents(string: http.urlString)?.queryDictionary ?? [:]
    }

}
