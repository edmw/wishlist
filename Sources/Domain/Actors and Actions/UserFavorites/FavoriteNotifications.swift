import NIO

// MARK: notifyItemCreate

extension NotificationSendingProvider {

    func notifyItemCreate(on list: List, for user: User)
        throws -> EventLoopFuture<Void>
    {
        return try self.dispatchSendItemCreateNotification(
            for: user.representation,
            on: list.representation,
            using: UserNotificationService.channels(for: user)
        )
    }

}

// MARK: EventLoopFuture

extension EventLoopFuture where Expectation == Favorite {

    func sendNotification(
        onItemCreateIn list: List,
        for user: User,
        using notificationSending: NotificationSendingProvider
    ) -> EventLoopFuture<Expectation> {
        return self.flatMap(to: Expectation.self) { favorite in
            return try notificationSending
                .notifyItemCreate(on: list, for: user)
                .transform(to: favorite)
        }
    }

}
