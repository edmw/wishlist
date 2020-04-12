import Vapor
import Html

import Foundation

/// Leaf template tag to render an action button:
/// - title: key for title
/// - icon: key for icon
/// - action: url to call on action
/// - method: method to use on action (if form post)
final class ActionButtonTag: TagRenderer {

    init() {
    }

    private func renderError(_ tag: TagContext, message: String) throws
        -> EventLoopFuture<TemplateData>
    {
        return EventLoopFuture.map(on: tag) {
            .string(Html.render(.spanError(message: message, label: "ActionButton")))
        }
    }

    private func buildForm(
        _ action: String,
        _ method: String,
        _ body: String? = nil,
        title: String,
        icon: String
    ) -> TemplateData {
        let methodNode: Node
        if method != "POST" {
            methodNode = Node
                .input(
                    attributes: [
                        .type(.hidden),
                        .name("__method"),
                        .value(method)
                    ]
                )
        }
        else {
            methodNode = Node()
        }
        let formNode = Node
            .form(
                attributes: [
                    .method(.post),
                    .action(action),
                    .class("form-inline d-inline-flex")
                ],
                .button(
                    attributes: [
                        .title(title),
                        .class("btn btn-action btn-link")
                    ],
                    .fragment([methodNode]),
                    .feather(icon: icon),
                    .raw(body ?? "")
                )
            )
        return .string(Html.render(formNode))
    }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let parametersCount = tag.parameters.count
        let parameters = tag.parameters
        guard parametersCount >= 3 else {
            return try renderError(tag, message: "not enough parameters")
        }
        guard let title = parameters[0].string else {
            return try renderError(tag, message: "parameter 'title' missing")
        }
        guard let icon = parameters[1].string else {
            return try renderError(tag, message: "parameter 'icon' missing")
        }
        guard let action = parameters[2].string else {
            return try renderError(tag, message: "parameter 'action' missing")
        }
        let method = (parametersCount >= 4 ? parameters[3].string?.uppercased() : nil) ?? "GET"

        let l10n = try tag.container.make(LocalizationService.self)
        let localizedTitle = try l10n.localize(in: tag, key: title) ?? "���"

        if method == "GET" {
            return EventLoopFuture.map(on: tag) {
                .string(Html.render(.aButton(action: action, title: localizedTitle, icon: icon)))
            }
        }
        else {
            if let body = tag.body {
                return tag.serializer.serialize(ast: body)
                    .map { body in
                        let encodedBody = String(data: body.data, encoding: .utf8)
                        return self.buildForm(
                            action,
                            method,
                            encodedBody,
                            title: localizedTitle,
                            icon: icon
                        )
                    }
            }
            else {
                return EventLoopFuture.map(on: tag) {
                    self.buildForm(action, method, title: localizedTitle, icon: icon)
                }
            }
        }
    }

}
