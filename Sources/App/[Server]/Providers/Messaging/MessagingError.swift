public enum MessagingError: Error {
    case emptyMessage
    case tooManyRecipients
    case response(status: UInt)
    case underlying(error: Error)
}
