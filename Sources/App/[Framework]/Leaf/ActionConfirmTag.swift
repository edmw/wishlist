import Vapor
import Html

import Foundation

/// Leaf template tag to render an action confirm button:
/// - title: key for title
final class ActionConfirmTag: TagRenderer {

    let danger: Bool

    let disabled: Bool

    init(danger: Bool = false, disabled: Bool = false) {
        self.danger = danger
        self.disabled = disabled
    }

    private func renderError(_ tag: TagContext, message: String) throws
        -> EventLoopFuture<TemplateData>
    {
        return EventLoopFuture.map(on: tag) {
            .string(Html.render(.spanError(message: message, label: "ActionConfirm")))
        }
    }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let parametersCount = tag.parameters.count
        let parameters = tag.parameters
        guard parametersCount >= 0 else {
            return try renderError(tag, message: "not enough parameters")
        }
        let title = (parametersCount >= 1 ? parameters[0].string : nil) ?? "confirm"

        let l10n = try tag.container.make(LocalizationService.self)
        let localizedTitle = try l10n.localize(in: tag, key: title) ?? "���"

        let buttonClass = danger ? "btn btn-danger" : "btn btn-primary"

        return EventLoopFuture.map(on: tag) {
            .string(
                Html.render(
                    .button(
                        attributes: [
                            .type(.submit),
                            .class(buttonClass),
                            .disabled(self.disabled)
                        ],
                        .text(localizedTitle)
                    )
                )
            )
        }
    }

}
