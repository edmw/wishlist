import Vapor

import Lingo

public class LocalizationService: Service {

    let config: LocalizationConfig

    var defaultLanguageCode: String {
        return self.config.defaultLanguageCode
    }

    let languageCodes: [String]

    init(_ config: LocalizationConfig, _ lingo: Lingo) throws {
        self.config = config
        self.languageCodes = try lingo.dataSource.availableLanguageCodes()
    }

    func locale(on request: Request) throws -> Locale {
        let requestLanguageCode
            = try request.pickLanguage(from: languageCodes, fallback: config.defaultLanguageCode)
                .lowercased()

        let languageCode: String
        if let resolver = config.requestResolver {
            languageCode = try resolver(requestLanguageCode, request)
        }
        else {
            languageCode = requestLanguageCode
        }

        return Locale(identifier: languageCode)
    }

    func localize(
        _ key: String,
        values: [String] = [],
        for languageCode: String?,
        on container: Container
    ) throws -> String? {
        let lingo: Lingo = try container.make()

        let interploations = values.reduce(into: [String: Any]()) { dictionary, value in
            dictionary["value" + String(dictionary.count + 1)] = value
        }

        let code = (languageCode ?? config.defaultLanguageCode).lowercased()
        let localized = lingo.localize(key, languageCode: code, interpolations: interploations)

        return localized != key ? localized : nil
    }

    func localize(
        _ key: String,
        values: [String] = [],
        on request: Request
    ) throws -> String? {
        let languageCode = try locale(on: request).languageCode
        return try localize(key, values: values, for: languageCode, on: request)
    }

    func localize(
        in tag: TagContext,
        key: String,
        values: [String] = []
    ) throws -> String? {
        let container = tag.container
        if let language = tag.context.userInfo["language"] as? String {
            return try localize(key, values: values, for: language, on: container)
        }
        else {
            if let request = container as? Request {
                return try localize(key, values: values, on: request)
            }
        }
        container.logger?.debug(
            "L10N: no localization\nKey: \(key)\nSource: \(tag.source)\n"
        )
        return nil
    }

    // MARK: Date

    func localize(date: Date, for locale: Locale) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    func localize(date: Date, for localeLanguageCode: String?) -> String? {
        let code = (localeLanguageCode ?? config.defaultLanguageCode).lowercased()
        return localize(date: date, for: Locale(identifier: code))
    }

    func localize(date: Date, on request: Request) throws -> String? {
        return try localize(date: date, for: locale(on: request))
    }

    // MARK: Locale

    func localize(languageCode: String, for locale: Locale) -> String? {
        return locale.localizedString(forLanguageCode: languageCode)
    }

    func localize(languageCode: String, for localeLanguageCode: String?) -> String? {
        let code = (localeLanguageCode ?? config.defaultLanguageCode).lowercased()
        return localize(languageCode: languageCode, for: Locale(identifier: code))
    }

    func localize(languageCode: String, on request: Request) throws -> String? {
        return try localize(languageCode: languageCode, for: locale(on: request))
    }

}

// MARK: -

extension Lingo {

    var defaultLanguageCode: String {
        return defaultLocale
    }

    func localize(
        _ key: LocalizationKey,
        languageCode: String?,
        interpolations: [String: Any]? = nil
    ) -> String {
        return localize(key, locale: languageCode ?? defaultLocale, interpolations: interpolations)
    }

}

extension LocalizationDataSource {

    func availableLanguageCodes() throws -> [String] {
        return try availableLocales()
    }

}
