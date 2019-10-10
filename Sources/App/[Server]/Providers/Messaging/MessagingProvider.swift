import Vapor

struct MessagingProvider: Provider {

    init() {
    }

    func register(_ services: inout Services) throws {
        if let pushoverApplicationToken = Environment.get(.pushoverApplicationToken) {
            services.register(PushoverService.self) { _ in
                return PushoverService(token: pushoverApplicationToken)
            }
        }
        services.register(MessagingService.self) { _ in
            return MessagingService()
        }
    }

    func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }

}
