import Vapor

struct LocalizationConfig {

    typealias RequestResolver = (_ requestLanguageCode: String, _ request: Request) throws -> String

    private(set) var defaultLanguageCode: String

    private(set) var localizationsDir: String

    private(set) var requestResolver: RequestResolver?

    init(defaultLanguage: String, localizationsDir: String = "Resources/Localizations") {
        self.defaultLanguageCode = defaultLanguage
        self.localizationsDir = DirectoryConfig.detect().workDir + localizationsDir
    }

    mutating func setRequestResolver(_ resolver: @escaping RequestResolver) {
        requestResolver = resolver
    }

}
