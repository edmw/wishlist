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
