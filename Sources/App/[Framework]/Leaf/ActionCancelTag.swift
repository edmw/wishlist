import Vapor
import Html

import Foundation

/// Leaf template tag to render an action cancel link:
/// - action: location to link to for this cancel action
/// A cancel action should be placed on the right side to a confirm action.
final class ActionCancelTag: TagRenderer {

    init() {
    }

    private func renderError(_ tag: TagContext, message: String) throws
        -> EventLoopFuture<TemplateData>
    {
        return EventLoopFuture.map(on: tag) {
            .string(Html.render(.spanError(message: message, label: "ActionCancel")))
        }
    }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let parametersCount = tag.parameters.count
        let parameters = tag.parameters
        guard parametersCount >= 1 else {
            return try renderError(tag, message: "not enough parameters")
        }
        guard var action = parameters[0].string else {
            return try renderError(tag, message: "parameter 'action' missing")
        }

        let l10n = try tag.container.make(LocalizationService.self)
        let localizedTitle = try l10n.localize(in: tag, key: "cancel") ?? "���"

        // request parameter 'p' overwrites action
        if let request = tag.container as? Request {
            if let location = request.query.getLocator(is: .local)?.locationString {
                action = location
            }
        }

        return EventLoopFuture.map(on: tag) {
            .string(
                Html.render(
                    .a(
                        attributes: [
                            .href(action),
                            .class("btn btn-link nav-link ml-3")
                        ],
                        .text(localizedTitle)
                    )
                )
            )
        }
    }

}
