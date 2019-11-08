import Vapor

// Pushover -- https://pushover.net/
//
// Limitations:
// Messages are currently limited to 1024 4-byte UTF-8 characters, with a title of up to 250
// characters. Supplementary URLs are limited to 512 characters, and URL titles to 100 characters.
final class PushoverService: Service {

    private let configuration: PushoverConfiguration

    init(configuration: PushoverConfiguration) {
        self.configuration = configuration
    }

    private struct PushMessage: Content {
        let token: String
        let user: String
        let message: String
        let title: String
        let html: Int
    }

    private struct ResponseMessage: Content {
        let status: UInt
        let request: String
        let receipt: String?
    }

    // Pushover API
    // HTTPS POST request to https://api.pushover.net/1/messages.json with the following parameters:
    // - token (required) - your application's token
    // - user (required) - your user's key
    // - message (required) - your message
    // - title - your message's title
    // - url - a supplementary URL to show with your message
    // - url_title - a title for your supplementary URL, otherwise just the URL is shown
    // A message may be sent to multiple users in one request by specifying a comma-separated list
    // (with no spaces) of user keys as the user parameter. These requests are currently limited to
    // 50 users in a single request.
    // If the POST request was valid, a HTTP 200 (OK) status will be sent. If any input was invalid,
    // a HTTP 4xx status will be sent.
    // (Note: if a notification can be sent to at least one user there will be no error. Even if
    // other user keys are invalid.)
    // @see https://pushover.net/api
    func send(
        text: String,
        title: String,
        for users: [PushoverUser],
        on container: Container
    ) throws -> EventLoopFuture<Void> {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MessagingError.emptyMessage
        }
        guard users.count <= 50 else {
            throw MessagingError.tooManyRecipients
        }

        let messagesUrl = "https://api.pushover.net/1/messages.json"

        let messagesData = PushMessage(
            token: configuration.applicationToken,
            user: users.joined(),
            message: text,
            title: title,
            html: 1
        )

        return try container.client()
            .post(messagesUrl) { messagesRequest in
                try messagesRequest.content.encode(messagesData)
            }
            .flatMap { response in
                guard response.http.status == .ok else {
                    container.requireLogger().error(
                        "Pushover service returned non-ok status \(response.http.status)"
                    )
                    return container.future(error: Abort(response.http.status))
                }
                return try response.content.decode(ResponseMessage.self)
                     .transform(to: ())
            }
    }

}
