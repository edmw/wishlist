import Vapor

// swiftlint:disable convenience_type

/// Controller for resources:
/// Defines some common functions to be of use in resources controllers.
class Controller {

    /// Returns the http method of the specified request. If the http method is POST there
    /// will be some speciality: A client can perfom a specific method other than POST
    /// by sending a POST request and including the parameter ´__method´. That way a
    /// web page, for example, can send a DELETE request by using a POST form.
    static func method(of request: Request) throws -> Future<HTTPMethod> {
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

    static func buildQuery(parameters: [ControllerParameter]) throws -> String? {
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
                if let queryString = try buildQuery(parameters: parameters) {
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
    ) -> Future<Response> {
        return request.future(redirect(to: location, type: type, on: request))
    }

    /// Returns a redirect response to the specified location for the given user
    /// on the specified request.
    static func redirect(
        for user: User,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) -> Response {
        let uid = ID(user.id) ??? ""
        return request.redirect(to: "/user/\(uid)/\(location)", type: type)
    }

    /// Returns a redirect response as a succeeded future to the specified location
    /// for the specified user on the specified request.
    static func redirect(
        for user: User,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) -> Future<Response> {
        return request.future(redirect(for: user, to: location, type: type, on: request))
    }

    /// Returns a redirect response to the specified location for the specified user
    /// and list on the specified request.
    static func redirect(
        for user: User,
        and list: List,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) -> Response {
        let uid = ID(user.id) ??? ""
        let listID = ID(list.id) ??? ""
        return request.redirect(to: "/user/\(uid)/list/\(listID)/\(location)", type: type)
    }

    /// Returns a redirect response as a succeeded future to the specified location
    /// for the specified user and list on the specified request.
    static func redirect(
        for user: User,
        and list: List,
        to location: String,
        type: RedirectType = .normal,
        on request: Request
    ) -> Future<Response> {
        return request.future(redirect(for: user, and: list, to: location, type: type, on: request))
    }

    /// Returns a redirect response to the specified wishlist on the specified request.
    static func redirect(
        for list: List,
        parameters: [ControllerParameter]? = nil,
        type: RedirectType = .normal,
        on request: Request
    ) -> Response {
        let listID = ID(list.id) ??? ""
        return redirect(to: "/list/\(listID)", parameters: parameters, type: type, on: request)
    }

    /// Returns a redirect response as a succeeded future to the specified wishlist
    /// on the specified request.
    static func redirect(
        for list: List,
        parameters: [ControllerParameter]? = nil,
        type: RedirectType = .normal,
        on request: Request
    ) -> Future<Response> {
        return request.future(redirect(for: list, parameters: parameters, type: type, on: request))
    }

    /// Renders a view with the specified template and the specified page context on the
    /// specified request.
    /// The given page context will be wrapped in a `RenderContext` and will be accessible from
    /// within the template by using the path `page`. The render context contains additional
    /// information for rendering the view such as the `features` path making the feature flags
    /// available to the template. Other additional information available is the site’s and the
    /// request’s parameters.
    static func renderView<E>(
        _ templateName: String,
        with pageContext: E,
        on request: Request
    ) throws -> Future<View> where E: Encodable {
        let site = try request.make(Site.self)
        let features = try request.make(Features.self)
        let context = RenderContext(pageContext, site: site, features: features)
        context.request += request.queryDictionary
        let locale = try request.make(LocalizationService.self).locale(on: request)
        return try request.view()
            .render(templateName, context, userInfo: ["language": locale.identifier])
    }

    /// Renders a view with the specified template and an empty page context on the
    /// specified request.
    static func renderView(
        _ templateName: String,
        on request: Request
    ) throws -> Future<View> {
        return try renderView(templateName, with: [String: String](), on: request)
    }

    /// Renders a localized view with the specified template and the specified page context on the
    /// specified request.
    /// Appends the template‘s base name with the user‘s language code separated by a dot.
    /// If the user‘s language code is not in the list of supported codes the default language code
    /// will be used.
    static func renderLocalizedView<E>(
        _ templateBaseName: String,
        with pageContext: E,
        on request: Request
    ) throws -> Future<View> where E: Encodable {
        let templateName: String
        let localization = try request.make(LocalizationService.self)
        let locale = try localization.locale(on: request)
        if let code = locale.languageCode, localization.languageCodes.contains(code) {
            templateName = "\(templateBaseName).\(code)"
        }
        else {
            let code = localization.defaultLanguageCode
            templateName = "\(templateBaseName).\(code)"
        }
        return try renderView(templateName, with: pageContext, on: request)
    }

    /// Renders a localized view with the specified template and an empty page context on the
    /// specified request.
    static func renderLocalizedView(
        _ templateBaseName: String,
        on request: Request
    ) throws -> Future<View> {
        return try renderLocalizedView(templateBaseName, with: [String: String](), on: request)
    }

}

extension Request {

    var queryDictionary: [String: String?] {
        return URLComponents(string: http.urlString)?.queryDictionary ?? [:]
    }

}
