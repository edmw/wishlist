import Vapor

struct EmailConfiguration: Service {

    let hostname: String
    let username: String
    let password: String

    let senderAddress: String
    let senderName: String

    // initialize from environment
    init() throws {
        self.hostname = try Environment.require(.emailSMTPHostname)
        self.username = try Environment.require(.emailSMTPUsername)
        self.password = try Environment.require(.emailSMTPPassword)

        self.senderAddress = try Environment.require(.emailSenderAddress)
        self.senderName = try Environment.require(.emailSenderName)
    }

    init(
        hostname: String,
        username: String,
        password: String,
        senderAddress: String,
        senderName: String
    ) {
        self.hostname = hostname
        self.username = username
        self.password = password
        self.senderAddress = senderAddress
        self.senderName = senderName
    }

}

extension EnvironmentKeys {
    static let emailSMTPHostname = EnvironmentKey<String>("EMAIL_SMTP_HOSTNAME")
    static let emailSMTPUsername = EnvironmentKey<String>("EMAIL_SMTP_USERNAME")
    static let emailSMTPPassword = EnvironmentKey<String>("EMAIL_SMTP_PASSWORD")
    static let emailSenderAddress = EnvironmentKey<String>("EMAIL_SENDER_ADDRESS")
    static let emailSenderName = EnvironmentKey<String>("EMAIL_SENDER_NAME")
}
