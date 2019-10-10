import Vapor

import Foundation

import Lingo

/// Leaf template tag to render localized language code.
/// Language used for localization will be detected from request.
/// L10NLocale() -> "Deutsch"
/// L10NLocale() -> "Français"
/// This can be used to display the language used for rendering templates to the user.
final class LocalizationLocaleTag: TagRenderer {

    init() {
    }

    func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let languageCode = tag.parameters[0].string

        var localized: String?

        if let languageCode = languageCode {
            let l10n = try tag.container.make(LocalizationService.self)

            if let language = tag.context.userInfo["language"] as? String {
                localized = l10n.localize(languageCode: languageCode, for: language)
            }
            else {
                if let request = tag.container as? Request {
                    localized = try l10n.localize(languageCode: languageCode, on: request)
                }
            }
        }

        let string = localized ?? "�"
        return Future.map(on: tag) { .string(string) }
    }

}
