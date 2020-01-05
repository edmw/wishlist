import Foundation
import NIO

public protocol UserNotificationsResult {
    var user: UserRepresentation { get }
    var sendingResults: [NotificationSendingResult] { get }
}
