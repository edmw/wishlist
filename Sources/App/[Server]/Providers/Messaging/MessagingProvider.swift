import Vapor

public struct MessagingProvider: Provider {

    init() {
    }

    public func register(_ services: inout Services) throws {
        services.register(EmailService.self) { container in
            return try EmailService(configuration: container.make())
        }
        services.register(PushoverService.self) { container in
            return try PushoverService(configuration: container.make())
        }
        services.register(MessagingService.self) { _ in
            return MessagingService()
        }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }

}
