import NIO

// MARK: notifyReservationCreate

extension NotificationSendingProvider {

    func notifyReservationCreate(for user: User, on item: Item, in list: List)
        throws -> EventLoopFuture<Void>
    {
        return try self.dispatchSendReservationCreateNotification(
            for: user.representation,
            on: item.representation,
            in: list.representation,
            using: UserNotificationService.channels(for: user)
        )
    }

    func notifyReservationDelete(for user: User, on item: Item, in list: List)
        throws -> EventLoopFuture<Void>
    {
        return try self.dispatchSendReservationDeleteNotification(
            for: user.representation,
            on: item.representation,
            in: list.representation,
            using: UserNotificationService.channels(for: user)
        )
    }

}

// MARK: EventLoopFuture

extension EventLoopFuture where Expectation == Reservation {

    func sendNotification(
        onCreateFor owner: User,
        on item: Item,
        in list: List,
        using notificationSending: NotificationSendingProvider
    ) -> EventLoopFuture<Expectation> {
        return self.flatMap(to: Expectation.self) { reservation in
            return try notificationSending
                .notifyReservationCreate(for: owner, on: item, in: list)
                .transform(to: reservation)
        }
    }

    func sendNotification(
        onDeleteFor owner: User,
        on item: Item,
        in list: List,
        using notificationSending: NotificationSendingProvider
    ) -> EventLoopFuture<Expectation> {
        return self.flatMap(to: Expectation.self) { reservation in
            return try notificationSending
                .notifyReservationDelete(for: owner, on: item, in: list)
                .transform(to: reservation)
        }
    }

}
