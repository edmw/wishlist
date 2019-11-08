import Vapor

import Foundation

import Lingo

/// Leaf template tag to render localized date:
/// Language used for localization will be detected from request.
final class LocalizationDateTag: TagRenderer {

    init() {
    }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireParameterCount(1)
        let interval = tag.parameters[0].double

        var localized: String?

        if let interval = interval {
            let l10n = try tag.container.make(LocalizationService.self)
            let date = Date(timeIntervalSince1970: interval)

            if let language = tag.context.userInfo["language"] as? String {
                localized = l10n.localize(date: date, for: language)
            }
            else {
                if let request = tag.container as? Request {
                    localized = try l10n.localize(date: date, on: request)
                }
            }
        }

        let string = localized ?? "�"
        return EventLoopFuture.map(on: tag) { .string(string) }
    }

}
