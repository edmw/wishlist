import Vapor

import Foundation

import Lingo

final class LocalizationDateTag: TagRenderer {

    init() {
    }

    func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let interval = tag.parameters[0].double

        let localized: String

        if let interval = interval, let request = tag.container as? Request {
            let l10n = try request.make(LocalizationService.self)
            let date = Date(timeIntervalSince1970: interval)
            localized = try l10n.localize(date: date, on: request) ?? "�"
        }
        else {
            localized = "�"
        }

        return Future.map(on: tag) { .string(localized) }
    }

}
