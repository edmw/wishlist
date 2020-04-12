import Vapor
import Html

import Foundation

/// Leaf template tag to render an icon:
/// - title: key for title
final class IconTag: TagRenderer {

    let type: Html.Node.IconType
    let style: Html.Node.IconStyle

    init(type: Html.Node.IconType, style: Html.Node.IconStyle) {
        self.type = type
        self.style = style
    }

    private func renderError(_ tag: TagContext, message: String) throws
        -> EventLoopFuture<TemplateData>
    {
        return EventLoopFuture.map(on: tag) {
            .string(Html.render(.spanError(message: message, label: "Icon")))
        }
    }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let parametersCount = tag.parameters.count
        let parameters = tag.parameters
        guard parametersCount == 1 else {
            return try renderError(tag, message: "not enough parameters")
        }
        guard let title = parameters[0].string else {
            return try renderError(tag, message: "parameter 'title' missing")
        }

        let l10n = try tag.container.make(LocalizationService.self)
        let localizedTitle = try l10n.localize(in: tag, key: title) ?? "���"

        return EventLoopFuture.map(on: tag) {
            .string(
                Html.render(
                    .icon(title: localizedTitle, type: self.type, style: self.style)
                )
            )
        }
    }

}
