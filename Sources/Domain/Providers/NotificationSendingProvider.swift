import Foundation
import NIO

// MARK: NotificationSendingProvider

public protocol NotificationSendingProvider {

    /// Sends a notification asynchronously when a reservation was added to an item.
    func dispatchSendReservationCreateNotification(
        for user: UserRepresentation,
        on item: ItemRepresentation,
        in list: ListRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<Void>

    /// Sends a notification asynchronously when a reservation was removed from an item.
    func dispatchSendReservationDeleteNotification(
        for user: UserRepresentation,
        on item: ItemRepresentation,
        in list: ListRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<Void>

    /// Sends a test notification to the specified user.
    func sendTestNotification(
        for user: UserRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<[NotificationSendingResult]>

}

// MARK: Channel

public enum NotificationSendingChannel: Hashable {

    case email(EmailSpecification)
    case pushover(PushoverKey)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .email:
            hasher.combine("email")
        case .pushover:
            hasher.combine("pushover")
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.email, .email):
            return true
        case (.pushover, .pushover):
            return true
        case (.email, _), (.pushover, _):
            return false
        }
    }

}

// MARK: Result

public protocol NotificationSendingResult {

    var channel: NotificationSendingChannel { get }
    var success: Bool { get }
    var status: UInt { get }

}
