public enum MessagingResult {
    case success(_ message: Message)
    case failure(_ message: Message, error: MessagingError)
}
