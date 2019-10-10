import Vapor

public class MessagingService: Service {

    public func send(_ message: Message, on container: Container) throws
        -> EventLoopFuture<MessagingResult>
    {
        switch message {
        case let .email(text, subject, addresses):
            return try container.make(EmailService.self)
                .send(text, subject, for: addresses, on: container)
                .transform(to: .success(message))
        case let .pushover(text, title, users):
            return try container.make(PushoverService.self)
                .send(text, title, for: users, on: container)
                .transform(to: .success(message))
                .catchMap { error in
                    if let error = error as? MessagingError {
                        return .failure(message, error: error)
                    }
                    else if let abort = error as? Abort {
                        return .failure(message, error: .response(status: abort.status.code))
                    }
                    throw error
                }
        }
    }

    public func send(_ messages: [Message], on container: Container) throws
        -> EventLoopFuture<[MessagingResult]>
    {
        var results: [EventLoopFuture<MessagingResult>] = []
        for message in messages {
            try results.append(send(message, on: container))
        }
        return results.flatten(on: container)
    }

}
