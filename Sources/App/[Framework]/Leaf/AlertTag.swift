import Vapor
import Html

import Foundation

/// Leaf template tag to render a alert:
/// - text: key for text
/// or html text in body
final class AlertTag: TagRenderer {

    let style: Html.Node.AlertStyle
    let dismissible: Bool

    init(style: Html.Node.AlertStyle, dismissible: Bool = false) {
        self.style = style
        self.dismissible = dismissible
    }

    private func renderError(_ tag: TagContext, message: String) throws
        -> EventLoopFuture<TemplateData>
    {
        return EventLoopFuture.map(on: tag) {
            .string(Html.render(.spanError(message: message, label: "Alert")))
        }
    }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let parametersCount = tag.parameters.count
        let parameters = tag.parameters
        guard parametersCount >= 0 else {
            return try renderError(tag, message: "not enough parameters")
        }
        let text = (parametersCount >= 1 ? parameters[0].string : nil)

        if let text = text {
            let l10n = try tag.container.make(LocalizationService.self)
            let localizedText = try l10n.localize(in: tag, key: text) ?? "���"

            return EventLoopFuture.map(on: tag) {
                .string(
                    Html.render(
                        .alert(
                            text: localizedText,
                            style: self.style,
                            dismissible: self.dismissible
                        )
                    )
                )
            }
        }
        else {
            if let body = tag.body {
                return tag.serializer.serialize(ast: body)
                    .map { body in
                        let encodedBody = String(data: body.data, encoding: .utf8)
                        return
                            .string(
                                Html.render(
                                    .alert(
                                        text: encodedBody ?? "",
                                        style: self.style,
                                        dismissible: self.dismissible
                                    )
                                )
                            )
                    }
            }
            else {
                return try renderError(tag, message: "parameter 'text' or body missing")
            }
        }
    }

}
