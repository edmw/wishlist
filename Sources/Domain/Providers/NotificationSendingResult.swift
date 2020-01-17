import Foundation

// MARK: Result

public protocol NotificationSendingResult {

    var channel: NotificationSendingChannel { get }
    var success: Bool { get }
    var status: UInt { get }

}
