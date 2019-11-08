public enum MessagingResult {
    case success(_ messaging: Messaging)
    case failure(_ messaging: Messaging, error: MessagingError)
}
