///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - configure
//
// Copyright (c) 2019-2020 Michael Baumgärtner
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////
// swiftlint:disable function_body_length

import Domain

import Vapor
import Leaf
import Authentication
import Fluent
import FluentMySQL

public func configure(
    _ config: inout Config,
    _ environment: inout Environment,
    _ services: inout Services
) throws {

    // MARK: Server configuration
    var serverConfig = NIOServerConfig.default()
    serverConfig.maxBodySize = 1_000_000
    serverConfig.supportCompression = false
    services.register(serverConfig)

    // MARK: Site configuration
    var site = try Site.detect()
    services.register(site)

    // MARK: Application Features

    let features = Features()
    services.register(features)

    // MARK: Logger

    let developmentLogLevel = Environment.get(.developmentLogLevel) ?? .debug
    let releaseLogLevel = Environment.get(.releaseLogLevel) ?? .error
    let logLevel = environment.isRelease ? releaseLogLevel : developmentLogLevel

    let loggingProvider = LoggingProvider(logLevel: logLevel)
    try services.register(loggingProvider)
    config.prefer(StandardLogger.self, for: Logger.self)

    // logger which can be used while configuring
    let logger = BasicLogger(level: logLevel, tag: "CONFIG")

    // MARK: Database

    try services.register(FluentMySQLProvider())

    var databasesConfig = DatabasesConfig()
    try databases(
        config: &databasesConfig,
        siteConfig: &site,
        environment: &environment,
        logger: logger
    )
    services.register(databasesConfig)

    var databasesMigrationsConfig = MigrationConfig()
    try databasesMigrations(
        config: &databasesMigrationsConfig,
        siteConfig: &site,
        environment: &environment,
        logger: logger
    )
    services.register(databasesMigrationsConfig)

    services.register(FluentUserRepository.self)
    services.register(FluentListRepository.self)
    services.register(FluentItemRepository.self)
    services.register(FluentFavoriteRepository.self)
    services.register(FluentReservationRepository.self)
    services.register(FluentInvitationRepository.self)
    config.prefer(FluentUserRepository.self, for: UserRepository.self)
    config.prefer(FluentListRepository.self, for: ListRepository.self)
    config.prefer(FluentItemRepository.self, for: ItemRepository.self)
    config.prefer(FluentFavoriteRepository.self, for: FavoriteRepository.self)
    config.prefer(FluentReservationRepository.self, for: ReservationRepository.self)
    config.prefer(FluentInvitationRepository.self, for: InvitationRepository.self)

    // MARK: register Services

    services.register(RequestLanguageService.self)
    services.register(ImageProxyService.self)

    // MARK: register Providers

    try services.register(AuthenticationProvider())

    try services.register(DispatchingProvider())
    try services.register(EmailConfiguration())
    try services.register(PushoverConfiguration())
    try services.register(MessagingProvider())

    // MARK: register Middlewares

    services.register(FileMiddleware.self)
    services.register(ImageFileMiddleware.self) { container -> ImageFileMiddleware in
        let workDir = try container.make(DirectoryConfig.self).workDir
        return ImageFileMiddleware(
            path: "/images/items/",
            directory: workDir + "Public-Images/"
        )
    }

    services.register(ErrorMiddleware.self)
    services.register(ErrorRendererMiddleware.self) { _ -> ErrorRendererMiddleware in
        return ErrorRendererMiddleware(
            template401: "Errors/401",
            template404: "Errors/404",
            templateServer: "Errors/Server",
            context: ["site": site]
        )
    }

    services.register(CachingHeadersMiddleware.self)
    services.register(SecurityHeadersMiddleware.self)

    services.register(SessionsMiddleware.self) { container in
        return try SessionsMiddleware(
            sessions: container.make(),
            config: makeSessionsConfig(container)
        )
    }

    var middlewaresConfig = MiddlewareConfig()
    try middlewares(
        config: &middlewaresConfig,
        siteConfig: &site,
        environment: &environment,
        logger: logger
    )
    services.register(middlewaresConfig)

    // MARK: Domain Providers

    services.register(VaporMessageLoggingProvider.self)
    config.prefer(VaporMessageLoggingProvider.self, for: MessageLoggingProvider.self)
    services.register(VaporEventRecordingProvider.self)
    config.prefer(VaporEventRecordingProvider.self, for: EventRecordingProvider.self)

    // MARK: Domain Actors

    services.register(DomainUserListsActor.self)
    services.register(DomainUserItemsActor.self)
    services.register(DomainUserFavoritesActor.self)
    services.register(DomainUserReservationsActor.self)
    services.register(DomainUserInvitationsActor.self)
    services.register(DomainUserProfileActor.self)
    services.register(DomainUserSettingsActor.self)
    services.register(DomainUserNotificationsActor.self)
    config.prefer(DomainUserListsActor.self, for: UserListsActor.self)
    config.prefer(DomainUserItemsActor.self, for: UserItemsActor.self)
    config.prefer(DomainUserFavoritesActor.self, for: UserFavoritesActor.self)
    config.prefer(DomainUserReservationsActor.self, for: UserReservationsActor.self)
    config.prefer(DomainUserInvitationsActor.self, for: UserInvitationsActor.self)
    config.prefer(DomainUserProfileActor.self, for: UserProfileActor.self)
    config.prefer(DomainUserSettingsActor.self, for: UserSettingsActor.self)
    config.prefer(DomainUserSettingsActor.self, for: UserSettingsActor.self)
    services.register(DomainUserWelcomeActor.self)
    config.prefer(DomainUserWelcomeActor.self, for: UserWelcomeActor.self)
    services.register(DomainEnrollmentActor.self)
    config.prefer(DomainEnrollmentActor.self, for: EnrollmentActor.self)
    services.register(DomainWishlistActor.self)
    config.prefer(DomainWishlistActor.self, for: WishlistActor.self)
    services.register(DomainAnnouncementsActor.self)
    config.prefer(DomainAnnouncementsActor.self, for: AnnouncementsActor.self)

    // MARK: Routes

    // Registering the router as a factory yields a separate router instance per eventloop
    // instead of a singleton router instance, resulting in thread-safe services and controllers.
    // @see https://github.com/vapor/vapor/issues/1711#issuecomment-408186604
    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router, container, features, logger: logger)
        return router
    }

    // MARK: Localization

    var localizationConfig = LocalizationConfig(defaultLanguage: "en")
    localizationConfig.setRequestResolver { requestLanguageCode, request in
        // language set in request query takes precedence over anything else
        if let queryLanguage: String = request.query["lang"] {
            return queryLanguage.lowercased()
        }
        // language set in request session should be the usual determining value
        if let userLanguage = try request.session().languageForUser {
            return userLanguage.lowercased()
        }
        // ultimately, language from request headers will be used
        return requestLanguageCode
    }
    try services.register(LocalizationProvider(localizationConfig))

    // MARK: Views

    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    var leafTagConfig = LeafTagConfig.default()
    leafTagConfig.use(LocalizationTag(), as: "L10N")
    leafTagConfig.use(LocalizationDateTag(), as: "L10NDate")
    leafTagConfig.use(LocalizationLocaleTag(), as: "L10NLocale")
    leafTagConfig.use(IconicButtonTag(), as: "IButton")
    services.register(leafTagConfig)

    //

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}

// MARK: SessionsConfig

func makeSessionsConfig(_ container: Container) -> SessionsConfig {
    return SessionsConfig(
        cookieName: "wishlist-session",
        cookieFactory: { string in
            return HTTPCookieValue(
                string: string,
                expires: Date(timeIntervalSinceNow: 60 * 60 * 24),
                maxAge: nil,
                domain: nil,
                path: "/",
                isSecure: false,
                isHTTPOnly: true,
                sameSite: .lax
            )
        }
    )
}

// MARK: Environment

extension EnvironmentKeys {
    static let developmentLogLevel = EnvironmentKey<LogLevel>("DEVELOPMENT_LOG_LEVEL")
    static let releaseLogLevel = EnvironmentKey<LogLevel>("RELEASE_LOG_LEVEL")
}

extension Environment {

    static func get(_ key: EnvironmentKey<LogLevel>) -> LogLevel? {
        guard let value = get(key.string) else {
            return nil
        }
        switch value {
        case "VERBOSE": return .verbose
        case "DEBUG": return .debug
        case "INFO": return .info
        case "WARNING": return .warning
        case "ERROR": return .error
        case "FATAL": return .fatal
        default:
            return nil
        }
    }

}
