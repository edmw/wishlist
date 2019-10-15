import Vapor

struct PushoverConfiguration: Service {

    let applicationToken: String

    // initialize from environment
    init() throws {
        guard let applicationToken = Environment.get(.pushoverApplicationToken) else {
            throw Abort(.internalServerError,
                reason: "Missing environment variable '\(EnvironmentKeys.pushoverApplicationToken)'"
            )
        }
        self.applicationToken = applicationToken
    }

    init(applicationToken: String) {
        self.applicationToken = applicationToken
    }

}

extension EnvironmentKeys {
    static let pushoverApplicationToken = EnvironmentKey<String>("PUSHOVER_APPLICATION_TOKEN")
}
