import Vapor

// MARK: SendNotificationResult

struct SendNotificationResult: JobResult {

    // true,if at least one message could be sent
    let success: Bool

    // send result of each message
    let messaging: [MessagingResult]

    init() {
        self.success = false
        self.messaging = []
    }

    init(messaging: [MessagingResult]) {
        self.messaging = messaging
        self.success = messaging.contains(where: { messaging in
            if case .success = messaging {
                return true
            }
            else {
                return false
            }
        })
    }

}
