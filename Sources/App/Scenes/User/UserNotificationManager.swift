import Vapor

// MARK: UserNotificationManager

final class UserNotificationManager: ServiceType {

    static var serviceSupports: [Any.Type] {
        return [UserNotificationManager.self]
    }

    static func makeService(for container: Container) throws
        -> UserNotificationManager
    {
        return .init(for: container)
    }

    let container: Container

    init(for container: Container) {
        self.container = container
    }

    func send(_ notification: UserNotification) throws -> EventLoopFuture<Void> {
        return try notification.dispatchSend(on: container)
            .transform(to: ())
    }

}

// MARK: - Future+UserNotification

extension EventLoopFuture {

    /// sends a notification
    func dispatchNotification(
        _ notification: UserNotification,
        on request: Request
    ) throws -> EventLoopFuture<Expectation> {
        return self.flatMap(to: Expectation.self) { value in
            return try request.make(UserNotificationManager.self)
                .send(notification)
                .transform(to: value)
        }
    }

    /// sends a notification which is build in the given closure
    func dispatchNotification(
        on request: Request,
        _ builder: @escaping (Request, Expectation) -> EventLoopFuture<UserNotification>?
    ) throws -> EventLoopFuture<Expectation> {
        return self.flatMap(to: Expectation.self) { value in
            guard let notificationFuture = builder(request, value) else {
                return request.future(value)
            }
            return notificationFuture
                .flatMap { notification in
                    return try request.make(UserNotificationManager.self)
                        .send(notification)
                        .transform(to: value)
                }
        }
    }

}
