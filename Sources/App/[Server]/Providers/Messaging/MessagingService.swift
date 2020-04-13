import Vapor

public class MessagingService: Service {

    public func send(_ messaging: Messaging, on container: Container) throws
        -> EventLoopFuture<MessagingResult>
    {
        switch messaging {
        case let .email(html, subject, addresses):
            return try container.make(EmailService.self)
                .send(html: html, subject: subject, for: addresses, on: container)
                .transform(to: .success(messaging))
                .catchMap { error in
                    return .failure(messaging, error: .underlying(error: error))
                }
        case let .pushover(simpleHtml, title, users):
            return try container.make(PushoverService.self)
                .send(text: simpleHtml, title: title, for: users, on: container)
                .transform(to: .success(messaging))
                .catchMap { error in
                    if let error = error as? MessagingError {
                        return .failure(messaging, error: error)
                    }
                    else if let abort = error as? Abort {
                        return .failure(messaging, error: .response(status: abort.status.code))
                    }
                    return .failure(messaging, error: .underlying(error: error))
                }
        }
    }

    public func send(_ messagings: [Messaging], on container: Container) throws
        -> EventLoopFuture<[MessagingResult]>
    {
        var results: [EventLoopFuture<MessagingResult>] = []
        for messaging in messagings {
            try results.append(send(messaging, on: container))
        }
        return results.flatten(on: container)
    }

}
