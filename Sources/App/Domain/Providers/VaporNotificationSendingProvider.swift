import Domain

import Vapor

// MARK: VaporNotificationSendingProvider

/// Adapter for the domain layers `NotificationSendingProvider` to be used with Vapor.
///
/// This delegates the work to the web app‘s notification sending framework.
struct VaporNotificationSendingProvider: NotificationSendingProvider {

    let request: Request

    init(on request: Request) {
        self.request = request
    }

    // func sendTestNotification
    // -> implemented in file `Scenes/User/TestNotification`

    // func dispatchSendReservationCreateNotification
    // -> implemented in file `Scenes/Reservations/ReservationCreateNotification`

    // func dispatchSendReservationDeleteNotification
    // -> implemented in file `Scenes/Reservations/ReservationDeleteNotification`

    /// Sends a notification to the specified user using the specified communication channels.
    /// - Parameter notification: the notification to be sent
    /// - Parameter user: the recipient for the notification
    /// - Parameter channels: the communication channels to be used for sending the notification
    /// - Parameter dispatch: see discussion
    ///
    /// If `dispatch` is set to true, this will return immediately after the sending jobs have been
    /// started. Result will be `nil` then. If `dispatch` is set to false, the results of the
    /// sending jobs will be collected and return (this will take noticeable longer, of course).
    func sendUserNotification(
        _ notification: UserNotification,
        for user: UserRepresentation,
        using channels: Set<NotificationSendingChannel>,
        dispatch: Bool = false
    ) throws -> EventLoopFuture<[NotificationSendingResult]?> {
        var notification = notification
        var email: NotificationSendingChannel?
        var pushover: NotificationSendingChannel?
        for channel in channels {
            switch channel {
            case let .email(specification):
                precondition(email == nil)
                email = channel
                notification.addEmailRecipient(
                    EmailAddress(specification: specification, name: user.fullName)
                )
            case let .pushover(key):
                precondition(pushover == nil)
                pushover = channel
                notification.addPushoverRecipient(PushoverUser(key: key))
            }
        }
        // map the app‘s messaging to a communication channel of the domain layer
        let map: (Messaging) -> NotificationSendingChannel? = {
            switch $0 {
            case .email:
                return email
            case .pushover:
                return pushover
            }
        }
        // map to sending result
        let result: (NotificationSendingChannel?, Bool, UInt) -> NotificationSendingResult? = {
            guard let channel = $0 else {
                return nil
            }
            return VaporNotificationSendingResult(channel: channel, success: $1, status: $2)
        }
        if dispatch {
            // send notification asynchronously (discard result)
            return try notification.dispatchSend(on: request).map { nil }
        }
        else {
            // send notification synchronously (return result)
            return try notification.send(on: request)
                .map { sendResult in
                    return sendResult.messaging.map { messagingResult in
                        switch messagingResult {
                        case let .success(messaging):
                            return result(map(messaging), true, 0)
                        case let .failure(messaging, error):
                            switch error {
                            case let .response(status):
                                return result(map(messaging), false, status)
                            default:
                                return result(map(messaging), false, 500)
                            }
                        }
                    }
                    .compactMap { $0 }
                }
        }
    }

    /// Sends a notification to the specified user using the specified communication channels
    /// with `dispatch` set to true.
    /// - Parameter notification: the notification to be sent
    /// - Parameter user: the recipient for the notification
    /// - Parameter channels: the communication channels to be used for sending the notification
    func dispatchSendUserNotification(
        _ notification: UserNotification,
        for user: UserRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<Void> {
        return try sendUserNotification(notification, for: user, using: channels, dispatch: true)
            .transform(to: ())
    }

}

// MARK: Result

struct VaporNotificationSendingResult: NotificationSendingResult, CustomStringConvertible {

    let channel: NotificationSendingChannel
    let success: Bool
    let status: UInt

    var description: String {
        return "VaporNotificationSendingResult"
            + "[channel: \(channel), success: \(success), status: \(status)]"
    }

}

// MARK: -

extension NotificationSendingChannel: CustomStringConvertible {

    public var description: String {
        switch self {
        case .email:
            return "email"
        case .pushover:
            return "pushover"
        }
    }

}

extension Array where Element: NotificationSendingResult {

    var description: String {
        return self.map { String(describing: $0) }.joined(separator: ", ")
    }

}
