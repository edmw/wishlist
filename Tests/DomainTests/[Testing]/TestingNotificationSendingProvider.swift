@testable import Domain
import NIO

struct TestingNotificationSendingProvider: NotificationSendingProvider {

    let worker: EventLoop

    init(worker: EventLoop) {
        self.worker = worker
    }

    func dispatchSendItemCreateNotification(
        for user: UserRepresentation,
        on list: ListRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<Void> {
        return worker.newSucceededFuture(result: ())
    }


    func dispatchSendReservationCreateNotification(
        for user: UserRepresentation,
        on item: ItemRepresentation,
        in list: ListRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<Void> {
        return worker.newSucceededFuture(result: ())
    }

    func dispatchSendReservationDeleteNotification(
        for user: UserRepresentation,
        on item: ItemRepresentation,
        in list: ListRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<Void> {
        return worker.newSucceededFuture(result: ())
    }

    func sendTestNotification(
        for user: UserRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<[NotificationSendingResult]> {
        return worker.newSucceededFuture(result: [])
    }

}
