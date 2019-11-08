import Vapor
import Leaf

import Lingo

struct LocalizationProvider: Provider {

    let config: LocalizationConfig

    init(_ config: LocalizationConfig) {
        self.config = config
    }

    func register(_ services: inout Services) throws {
        let defaultLanguageCode = config.defaultLanguageCode
        let localizationsDir = config.localizationsDir
        // register Lingo as a service
        services.register(Lingo.self) { _ -> Lingo in
            return try Lingo(rootPath: localizationsDir, defaultLocale: defaultLanguageCode)
        }
        // register Localization as a service
        services.register { container -> LocalizationService in
            return try LocalizationService(self.config, container.make())
        }
    }

    func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }

}

extension Lingo: Service {}

extension Container {

    func lingo() throws -> Lingo {
        return try self.make(Lingo.self)
    }

}
