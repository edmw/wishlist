import Vapor

/// This provides a `StandardLogger` configured with the given log levels.
struct LoggingProvider: Provider {

    let logLevel: LogLevel

    let technicalLogLevel: LogLevel
    let applicationLogLevel: LogLevel
    let businessLogLevel: LogLevel

    init(
        logLevel: LogLevel = .error,
        technicalLogLevel: LogLevel? = nil,
        applicationLogLevel: LogLevel? = nil,
        businessLogLevel: LogLevel? = nil
    ) {
        self.logLevel = logLevel
        self.technicalLogLevel = technicalLogLevel ?? logLevel
        self.applicationLogLevel = applicationLogLevel ?? logLevel
        self.businessLogLevel = businessLogLevel ?? logLevel
    }

    func register(_ services: inout Services) throws {
        services.register([Logger.self, StandardLogger.self]) { _ in
            return StandardLogger(
                technicalLogLevel: self.technicalLogLevel,
                applicationLogLevel: self.applicationLogLevel,
                businessLogLevel: self.businessLogLevel
            )
        }
    }

    func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }

}

// MARK: -

/// This extension adds convenience properties to containers to create a topic logger.
/// In case of an error the variable returns `nil` which can be useful for optional logging,
/// while the first function throws. Finally, the second function will fatally exit.
extension Container {

    var logger: StandardLogger? {
        return try? self.make(StandardLogger.self)
    }

    func makeLogger() throws -> StandardLogger {
        return try self.make(StandardLogger.self)
    }

    func requireLogger() -> StandardLogger {
        guard let instance = try? self.make(StandardLogger.self) else {
            fatalError("Container: Constructing a Logger failed!")
        }
        return instance
    }

}
