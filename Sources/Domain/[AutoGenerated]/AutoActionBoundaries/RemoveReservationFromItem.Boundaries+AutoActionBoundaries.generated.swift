// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import NIO

// MARK: RemoveReservationFromItem.Boundaries

extension RemoveReservationFromItem.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        notificationSending notificationsending: NotificationSendingProvider
    ) -> Self {
        return Self(
            worker: worker,
            notificationSending: notificationsending
        )
    }

}
