public enum NotificationError: Error {
    case response(status: UInt)
    case tooManyRecipients
}
