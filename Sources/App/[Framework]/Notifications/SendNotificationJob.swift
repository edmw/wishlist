import Vapor
import Leaf

// MARK: SendNotificationJob

final class SendNotificationJob: DispatchableJob<SendNotificationResult> {

    let notification: Notification

    init(
        for notification: Notification,
        on container: Container,
        at date: Date = Date(),
        before deadline: Date = .distantFuture
    ) {
        self.notification = notification
        super.init(on: container, at: date, before: deadline)
    }

    override func run(_ context: JobContext) -> EventLoopFuture<SendNotificationResult> {
        let container = context.container
        return notification
            .render(on: container)
            .flatMap { message in
                let user = self.notification.user

                var messages: [Message] = []

                if user.settings.notifications.pushoverEnabled {
                    let key = user.settings.notifications.pushoverKey
                    messages.append(
                        .pushover(message: message.text, title: message.title, users: [key])
                    )
                }

                guard messages.isNotEmpty else {
                    // no messages to send
                    return context.eventLoop.future(SendNotificationResult())
                }

                return try container.make(MessagingService.self)
                    .send(messages, on: container)
                    .flatMap { messagingResults in
                        // return result with messaging results
                        let result = SendNotificationResult(messaging: messagingResults)
                        return context.eventLoop.future(result)
                    }
            }
    }

    // MARK: CustomStringConvertible

    override var description: String {
        return "SendNotificationJob(\(notification), at: \(scheduled))"
    }

}
