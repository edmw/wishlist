import Vapor

import Foundation

import Lingo

final class LocalizationLocaleTag: TagRenderer {

    init() {
    }

    func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let languageCode = tag.parameters[0].string

        let localized: String

        if let languageCode = languageCode, let request = tag.container as? Request {
            let l10n = try request.make(LocalizationService.self)
            localized = try l10n.localize(languageCode: languageCode, on: request) ?? "�"
        }
        else {
            localized = "�"
        }

        return Future.map(on: tag) { .string(localized) }
    }

}
