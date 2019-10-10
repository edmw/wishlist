public enum MessagingError: Error {
    case response(status: UInt)
    case tooManyRecipients
}
