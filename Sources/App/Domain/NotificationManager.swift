import Vapor

// MARK: NotificationManager

final class NotificationManager: ServiceType {

    static var serviceSupports: [Any.Type] {
        return [NotificationManager.self]
    }

    static func makeService(for container: Container) throws
        -> NotificationManager
    {
        return .init(for: container)
    }

    let container: Container

    init(for container: Container) {
        self.container = container
    }

    func send(_ notification: Notification) throws -> EventLoopFuture<Void> {
        guard try container.makeFeatures().userNotifications.enabled else {
            return container.future(())
        }
        return try notification.dispatchSend(on: container)
            .transform(to: ())
    }

}

// MARK: - Future+Notification

extension Future {

    /// sends a notification
    func dispatchNotification(
        _ notification: Notification,
        on request: Request
    ) throws -> Future<Expectation> {
        return self.flatMap(to: Expectation.self) { value in
            return try request.make(NotificationManager.self)
                .send(notification)
                .transform(to: value)
        }
    }

    /// sends a notification which is build in the given closure
    func dispatchNotification(
        on request: Request,
        _ notificationBuilder: @escaping (Request) -> EventLoopFuture<Notification?>
    ) throws -> Future<Expectation> {
        return self.flatMap(to: Expectation.self) { value in
            return notificationBuilder(request)
                .flatMap { notification in
                    guard let notification = notification else {
                        return request.future(value)
                    }
                    return try request.make(NotificationManager.self)
                        .send(notification)
                        .transform(to: value)
                }
        }
    }

}
