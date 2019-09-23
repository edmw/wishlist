import Vapor

final class PushoverNotifications: Service {

    private let token: String

    init(token: String) {
        self.token = token
    }

    private struct PushMessage: Content {
        let token: String
        let user: String
        let message: String
        let title: String
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
    // a HTTP 4xx status will sent.
    // (Note: if a notification can be sent to at least one user there will be no error. Even if
    // other user keys are invalid.)
    // @see https://pushover.net/api
    func emit(_ message: String, _ title: String, for users: [String], on request: Request) throws
        -> EventLoopFuture<Void>
    {
        guard users.count <= 50 else {
            throw NotificationError.tooManyRecipients
        }

        let messagesUrl = "https://api.pushover.net/1/messages.json"

        let messagesData = PushMessage(
            token: token,
            user: users.joined(separator: ","),
            message: message,
            title: title
        )

        return try request.client()
            .post(messagesUrl) { messagesRequest in
                try messagesRequest.content.encode(messagesData)
            }
            .flatMap { response in
                guard response.http.status == .ok else {
                    request.requireLogger().error(
                        "Pushover service returned non-ok status \(response.http.status)"
                    )
                    return request.future(error: Abort(response.http.status))
                }
                return try response.content.decode(ResponseMessage.self)
                     .transform(to: ())
            }
    }

}

extension EnvironmentKeys {
    static let pushoverApplicationToken = EnvironmentKey<String>("PUSHOVER_APPLICATION_TOKEN")
}
