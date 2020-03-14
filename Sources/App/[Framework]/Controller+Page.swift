import Vapor

/// Controller for resources:
/// Defines some common functions to be of use in resources controllers.
extension Controller {

    static func render(page: Page, on request: Request) throws -> EventLoopFuture<View> {
        return try renderView(page.template, with: page.context, on: request)
    }

    /// Renders a view with the specified template and the specified page context on the
    /// specified request.
    /// The given page context will be wrapped in a `RenderContext` and will be accessible from
    /// within the template by using the path `page`. The render context contains additional
    /// information for rendering the view such as the `features` path making the feature flags
    /// available to the template. Other additional information available are the site’s and the
    /// request’s parameters.
    static func renderView(
        _ pageTemplate: PageTemplate,
        with pageContext: PageContext? = nil,
        on request: Request
    ) throws -> EventLoopFuture<View> {
        let anyPageContext = pageContext.map(AnyPageContext.init)

        let site = try request.make(Site.self)
        let features = try request.make(Features.self)
        let renderContext = RenderContext(anyPageContext, site: site, features: features)
        renderContext.request += request.queryDictionary

        let localization = try request.make(LocalizationService.self)
        let locale = try localization.locale(on: request)
        let templateName: String
        if pageTemplate.isLocalized {
            if let code = locale.languageCode, localization.languageCodes.contains(code) {
                templateName = "\(pageTemplate.name).\(code)"
            }
            else {
                let code = localization.defaultLanguageCode
                templateName = "\(pageTemplate.name).\(code)"
            }
        }
        else {
            templateName = pageTemplate.name
        }

        if let logger = request.logger, logger.technicalLogLevel == .verbose {
            let jsonencoder = JSONEncoder()
            jsonencoder.outputFormatting = [.prettyPrinted]
            jsonencoder.dateEncodingStrategy = .iso8601
            if let jsondata = try? jsonencoder.encode(anyPageContext),
               let jsonstring = String(data: jsondata, encoding: .utf8)
            {
                logger.technical.verbose("Controller.renderView: PageContext " + jsonstring)
            }
        }

        return try request.view()
            .render(templateName, renderContext, userInfo: ["language": locale.identifier])
    }

}
