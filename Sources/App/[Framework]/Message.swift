import Vapor

// MARK: Message

protocol Message {

    func messagings(on container: Container) -> EventLoopFuture<[Messaging]>

    @discardableResult
    func send(on container: Container, at date: Date, before deadline: Date) throws
        -> EventLoopFuture<SendMessageResult>

    @discardableResult
    func dispatchSend(on container: Container, at date: Date, before deadline: Date) throws
        -> EventLoopFuture<Void>

}

extension Message {

    @discardableResult
    func send(
        on container: Container,
        at date: Date = Date(),
        before deadline: Date = .distantFuture
    ) throws
        -> EventLoopFuture<SendMessageResult>
    {
        let job = SendMessageJob(for: self, on: container, at: date, before: deadline)
        let jobService = try container.make(DispatchingService.self)
        return try jobService.dispatch(job)
            .transform(to: job.completed)
    }

    @discardableResult
    func dispatchSend(
        on container: Container,
        at date: Date = Date(),
        before deadline: Date = .distantFuture
    ) throws
        -> EventLoopFuture<Void>
    {
        let job = SendMessageJob(for: self, on: container, at: date, before: deadline)
        let jobService = try container.make(DispatchingService.self)
        return try jobService.dispatch(job)
    }

}

// MARK: MessageContent

struct MessageContent {
    let text: String
    let title: String
}

// MARK: - TextMessage

protocol TextMessage: Message {

    /// renders text template
    func render(on container: Container) -> EventLoopFuture<MessageContent>

    /// returns recipients for pushover messaging, empty if no pushover messages should be sent
    var pushoverRecipients: [PushoverUser] { get set }

}

extension TextMessage {

    func messagings(on container: Container) -> EventLoopFuture<[Messaging]> {
        return textMessagings(on: container)
    }

    fileprivate func textMessagings(on container: Container) -> EventLoopFuture<[Messaging]> {
        return render(on: container).map { content in

            var messagings: [Messaging] = []

            if !self.pushoverRecipients.isEmpty {
                messagings.append(
                    .pushover(
                        message: content.text,
                        title: content.title,
                        users: self.pushoverRecipients
                    )
                )
            }

            return messagings
        }
    }

    mutating func addPushoverRecipient(_ pushoverUser: PushoverUser) {
        pushoverRecipients.append(pushoverUser)
    }

}

// MARK: - HTMLMessage

protocol HTMLMessage: Message {

    /// renders html template (fallback should be text wrapped in <html>)
    func renderHTML(on container: Container) -> EventLoopFuture<MessageContent>

    /// returns recipients for email messaging, empty if no email messages should be sent
    var emailRecipients: [EmailAddress] { get set }

}

extension HTMLMessage {

    func messagings(on container: Container) -> EventLoopFuture<[Messaging]> {
        return htmlMessagings(on: container)
    }

    fileprivate func htmlMessagings(on container: Container) -> EventLoopFuture<[Messaging]> {
        return renderHTML(on: container).map { htmlContent in

            var messagings: [Messaging] = []

            if !self.emailRecipients.isEmpty {
                messagings.append(
                    .email(
                        message: htmlContent.text,
                        subject: htmlContent.title,
                        addresses: self.emailRecipients
                    )
                )
            }

            return messagings
        }
    }

    mutating func addEmailRecipient(_ emailAddress: EmailAddress) {
        emailRecipients.append(emailAddress)
    }

}

// MARK: - MultiMessage

protocol MultiMessage: TextMessage, HTMLMessage {
}

extension MultiMessage {

    func messagings(on container: Container) -> EventLoopFuture<[Messaging]> {
        let futureTextMessagings = textMessagings(on: container)
        let futureHtmlMessagings = htmlMessagings(on: container)
        return map(futureTextMessagings, futureHtmlMessagings) { textMessagings, htmlMessagings in
            return textMessagings + htmlMessagings
        }
    }

}
