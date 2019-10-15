import Vapor

struct MessagingProvider: Provider {

    init() {
    }

    func register(_ services: inout Services) throws {
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

    func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }

}
