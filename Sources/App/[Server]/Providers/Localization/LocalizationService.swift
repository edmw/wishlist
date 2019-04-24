import Vapor

import Lingo

public class LocalizationService: Service {

    let languageCodes: [String]

    init(_ lingo: Lingo) throws {
        self.languageCodes = try lingo.dataSource.availableLanguageCodes()
    }

    func locale(on request: Request) throws -> Locale {
        let lingo = try request.make(Lingo.self)

        var languageCode = lingo.defaultLanguageCode

        if let user = try request.authenticated(User.self), let userLanguage = user.language {
            languageCode = userLanguage.lowercased()
        }
        else {
            let requestLanguage = try request.privateContainer.make(RequestLanguageService.self)
                .pick(
                    from: languageCodes,
                    on: request,
                    fallback: languageCode
                )
            languageCode = requestLanguage.lowercased()
        }
        return Locale(identifier: languageCode)
    }

    func localize(key: String, values: [String] = [], on request: Request) throws -> String? {
        let lingo = try request.make(Lingo.self)
        let languageCode = try locale(on: request).languageCode

        let interploations = values.reduce(into: [String: Any]()) { dictionary, value in
            dictionary["value" + String(dictionary.count + 1)] = value
        }

        let localized
            = lingo.localize(key, languageCode: languageCode, interpolations: interploations)

        return localized != key ? localized : nil
    }

    // MARK: Date

    func localize(date: Date, on request: Request) throws -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = try locale(on: request)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    // MARK: Locale

    func localize(languageCode: String, on request: Request) throws -> String? {
        return try locale(on: request).localizedString(forLanguageCode: languageCode)
    }

}

// MARK: -

extension RequestLanguageService {

    func pick(
        from languageCodes: [String],
        on request: Request,
        fallback: String
    ) throws -> String {
        guard !languageCodes.isEmpty else {
            return fallback
        }

        let languages = try parse(on: request)
        guard !languages.isEmpty else {
            return fallback
        }

        for language in languages {
            if languageCodes.contains(
                where: { $0.caseInsensitiveCompare(language.code) == .orderedSame }
            ) {
                return language.code
            }
        }

        return fallback
    }

}

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
