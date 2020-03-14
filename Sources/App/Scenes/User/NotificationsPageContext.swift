import Domain

import Foundation

struct NotificationResultContext: Encodable {

    let service: String
    let success: Bool
    let status: UInt

}

struct NotificationsPageContext: PageContext {

    var actions = PageActions()

    var userID: ID?

    var success: Bool

    var results: [NotificationResultContext]

    init(for user: UserRepresentation) {
        self.userID = ID(user.id)

        self.success = false

        self.results = []
    }

    init(_ result: UserNotificationsResult, for user: UserRepresentation) {
        self.userID = ID(user.id)

        self.success = result.sendingResults.allSatisfy{ $0.success }

        self.results = result.sendingResults.map { result -> NotificationResultContext in
            .init(
                service: String(describing: result.channel),
                success: result.success,
                status: result.status
            )
        }
    }

}
