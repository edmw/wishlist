import Vapor

import Foundation

import Lingo

/// Leaf template tag to render localized text:
/// Language used for localization will be taken from user info or detected from request.
/// L10N("<key>") { <defaulttext> }
/// L10N("<key>", "<value1>", ... "<valueN>") { <defaulttext> }
/// - key: key used to lookup localized text in localization file
/// - defaulttext: text to be rendered if localization is not available for key
/// - valueN: string value to be used for string interpolation of localization for key
/// To set language from code using user info:
///     ... .render("template", ["foo": "bar"], userInfo: ["language": "<languageCode>"])
final class LocalizationTag: TagRenderer {

    init() {
    }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let key = tag.parameters[0].string
        let values = tag.parameters.count > 1 ? tag.parameters[1...].map { $0.string ?? "�" } : []

        var localized: String?

        if let key = key {
            let l10n = try tag.container.make(LocalizationService.self)
            localized = try l10n.localize(in: tag, key: key, values: values)
        }

        if let localized = localized {
            return EventLoopFuture.map(on: tag) { .string(localized) }
        }
        else {
            if let body = tag.body {
                return tag.serializer.serialize(ast: body)
                    .map { body in
                        return .string(String(data: body.data, encoding: .utf8) ?? "")
                    }
            }
            else {
                return EventLoopFuture.map(on: tag) { .string("���") }
            }
        }
    }

}
