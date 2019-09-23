import Vapor

public class NotificationService: Service {

    public func emit(_ notification: Notification, on request: Request) throws
        -> EventLoopFuture<NotificationResult>
    {
        switch notification {
        case let .email(message, subject, addresses):
            return try request.make(EmailNotifications.self)
                .emit(message, subject, for: addresses, on: request)
                .transform(to: .success(notification))
        case let .pushover(message, title, users):
            return try request.make(PushoverNotifications.self)
                .emit(message, title, for: users, on: request)
                .transform(to: .success(notification))
                .catchMap { error in
                    if let error = error as? NotificationError {
                        return .failure(notification, error: error)
                    }
                    else if let abort = error as? Abort {
                        return .failure(notification, error: .response(status: abort.status.code))
                    }
                    throw error
                }
        default:
            return request.future(error: Abort(.serviceUnavailable))
        }
    }

    public func emit(_ notifications: [Notification], on request: Request) throws
        -> EventLoopFuture<[NotificationResult]>
    {
        var results: [EventLoopFuture<NotificationResult>] = []
        for notification in notifications {
            try results.append(emit(notification, on: request))
        }
        return results.flatten(on: request)
    }

}
