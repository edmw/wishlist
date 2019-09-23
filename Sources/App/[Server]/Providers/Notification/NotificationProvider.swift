import Vapor

struct NotificationProvider: Provider {

    init() {
    }

    func register(_ services: inout Services) throws {
        if let pushoverApplicationToken = Environment.get(.pushoverApplicationToken) {
            services.register(PushoverNotifications.self) { _ in
                return PushoverNotifications(token: pushoverApplicationToken)
            }
        }
        services.register(NotificationService.self) { _ in
            return NotificationService()
        }
    }

    func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }

}
