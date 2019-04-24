import Vapor
import Leaf

import Lingo

struct LocalizationProvider: Provider {

    let defaultLocale: String
    let rootPath: String

    init(defaultLocale: String, localizationsDir: String = "Resources/Localizations") {
        self.defaultLocale = defaultLocale
        self.rootPath = DirectoryConfig.detect().workDir + localizationsDir
    }

    func register(_ services: inout Services) throws {
        // register Lingo as a service
        services.register(Lingo.self) { _ -> Lingo in
            return try Lingo(rootPath: self.rootPath, defaultLocale: self.defaultLocale)
        }
        // register Localization as a service
        services.register { container -> LocalizationService in
            return try LocalizationService(container.make(Lingo.self))
        }
    }

    func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }

}

extension Lingo: Service {}

extension Container {

    func lingo() throws -> Lingo {
        return try self.make(Lingo.self)
    }

}
