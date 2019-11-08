///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - configure
//
// Copyright (c) 2019 Michael Baumgärtner
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

    let loggingProvider = LoggingProvider(logLevel: environment.isRelease ? .error : .debug)
    try services.register(loggingProvider)
    config.prefer(StandardLogger.self, for: Logger.self)

    // logger which can be used while configuring
    let logger = BasicLogger(
        level: environment.isRelease ? .error : .debug,
        tag: "CONFIG"
    )

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

    services.register(MySQLUserRepository.self)
    services.register(MySQLListRepository.self)
    services.register(MySQLItemRepository.self)
    services.register(MySQLFavoriteRepository.self)
    services.register(MySQLReservationRepository.self)
    services.register(MySQLInvitationRepository.self)
    config.prefer(MySQLUserRepository.self, for: UserRepository.self)
    config.prefer(MySQLListRepository.self, for: ListRepository.self)
    config.prefer(MySQLItemRepository.self, for: ItemRepository.self)
    config.prefer(MySQLFavoriteRepository.self, for: FavoriteRepository.self)
    config.prefer(MySQLReservationRepository.self, for: ReservationRepository.self)
    config.prefer(MySQLInvitationRepository.self, for: InvitationRepository.self)

    // MARK: register Services

    services.register(RequestLanguageService.self)
    services.register(ImageProxyService.self)

    // MARK: register Providers

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

    // MARK: Routes

    try services.register(AuthenticationProvider())

    let router = EngineRouter.default()
    try routes(router, features, logger: logger)
    services.register(router, as: Router.self)

    // MARK: Localization

    var localizationConfig = LocalizationConfig(defaultLanguage: "en")
    localizationConfig.setRequestResolver { requestLanguageCode, request in
        if let queryLanguage: String = request.query["lang"] {
            return queryLanguage.lowercased()
        }
        if let user = try request.authenticated(User.self), let userLanguage = user.language {
            return userLanguage.lowercased()
        }
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
    services.register(leafTagConfig)

    // MARK: Managers

    services.register(UserNotificationManager.self)

    //

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}

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
