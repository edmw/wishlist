import Vapor

final class EmailService: Service {

    private let hostname: String
    private let username: String
    private let password: String

    init(hostname: String, username: String, password: String) {
        self.hostname = hostname
        self.username = username
        self.password = password
    }

    func send(
        _ text: String,
        _ subject: String,
        for addresses: [String],
        on container: Container
    ) throws
        -> EventLoopFuture<Void>
    {
        guard addresses.count <= 50 else {
            throw MessagingError.tooManyRecipients
        }

        return container.future(())
    }

}

extension EnvironmentKeys {
    static let emailSMTPHostname = EnvironmentKey<String>("EMAIL_SMTP_HOSTNAME")
    static let emailSMTPUsername = EnvironmentKey<String>("EMAIL_SMTP_USERNAME")
    static let emailSMTPPassword = EnvironmentKey<String>("EMAIL_SMTP_PASSWORD")
}
