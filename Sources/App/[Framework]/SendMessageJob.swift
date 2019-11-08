import Vapor
import Leaf

// MARK: SendMessageJob

final class SendMessageJob: DispatchableJob<SendMessageResult> {

    let message: Message

    init(
        for message: Message,
        on container: Container,
        at date: Date = Date(),
        before deadline: Date = .distantFuture
    ) {
        self.message = message
        super.init(on: container, at: date, before: deadline)
    }

    override func run(_ context: JobContext) -> EventLoopFuture<SendMessageResult> {
        let container = context.container

        return message.messagings(on: container).flatMap { messagings in
            guard messagings.isNotEmpty else {
                // no messages to send
                return context.eventLoop.future(SendMessageResult())
            }

            return try container.make(MessagingService.self)
                .send(messagings, on: container)
                .flatMap { messagingResults in
                    // return result with messaging results
                    let result = SendMessageResult(messaging: messagingResults)
                    return context.eventLoop.future(result)
                }
        }
    }

    // MARK: CustomStringConvertible

    override var description: String {
        return "SendMessageJob(\(message), at: \(scheduled))"
    }

}
