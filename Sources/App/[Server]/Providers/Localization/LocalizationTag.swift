import Vapor

import Foundation

import Lingo

final class LocalizationTag: TagRenderer {

    init() {
    }

    func render(tag: TagContext) throws -> Future<TemplateData> {
        let body = try tag.requireBody()
        let key = tag.parameters[0].string
        let values = tag.parameters.count > 1 ? tag.parameters[1...].map { $0.string ?? "�" } : []

        let localized: String?

        if let key = key, let request = tag.container as? Request {
            let l10n = try request.make(LocalizationService.self)
            localized = try l10n.localize(key: key, values: values, on: request)
        }
        else {
            localized = nil
        }

        if let localized = localized {
            return Future.map(on: tag) { .string(localized) }
        }
        else {
            return tag.serializer.serialize(ast: body)
                .map(to: TemplateData.self) { body in
                    return .string(String(data: body.data, encoding: .utf8) ?? "")
                }
        }
    }

}
