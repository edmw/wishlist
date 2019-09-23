public enum NotificationResult {
    case success(_ notification: Notification)
    case failure(_ notification: Notification, error: NotificationError)
}
