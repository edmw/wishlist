import Vapor

import SwiftSMTP

final class EmailService: Service {

    private let configuration: EmailConfiguration

    init(configuration: EmailConfiguration) {
        self.configuration = configuration
    }

    func send(
        html: String,
        subject: String,
        for addresses: [String],
        on container: Container
    ) throws
        -> EventLoopFuture<Void>
    {
        guard !html.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MessagingError.emptyMessage
        }
        guard addresses.count <= 50 else {
            throw MessagingError.tooManyRecipients
        }

        let smtp = SMTP(
            hostname: configuration.hostname,
            email: configuration.username,
            password: configuration.password
        )

        let sender = Mail.User(name: configuration.senderName, email: configuration.senderAddress)
        let recipients = addresses.map { Mail.User(email: $0) }

        let mail = Mail(
            from: sender,
            to: recipients,
            subject: subject,
            attachments: [Attachment(htmlContent: html)]
        )

        let promise = container.eventLoop.newPromise(Void.self)

        smtp.send(mail) { error in
            if let error = error {
                promise.fail(error: error)
            }
            else {
                promise.succeed(result: ())
            }
        }

        return promise.futureResult
    }

}
