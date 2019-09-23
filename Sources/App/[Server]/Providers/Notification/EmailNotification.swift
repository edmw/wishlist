import Vapor

final class EmailNotifications: Service {

    private let hostname: String
    private let username: String
    private let password: String

    init(hostname: String, username: String, password: String) {
        self.hostname = hostname
        self.username = username
        self.password = password
    }

    func emit(
        _ message: String,
        _ subject: String,
        for addresses: [String],
        on request: Request
    ) throws
        -> EventLoopFuture<Void>
    {
        guard addresses.count <= 50 else {
            throw NotificationError.tooManyRecipients
        }

        return request.future(())
    }

}

extension EnvironmentKeys {
    static let emailSMTPHostname = EnvironmentKey<String>("EMAIL_SMTP_HOSTNAME")
    static let emailSMTPUsername = EnvironmentKey<String>("EMAIL_SMTP_USERNAME")
    static let emailSMTPPassword = EnvironmentKey<String>("EMAIL_SMTP_PASSWORD")
}
