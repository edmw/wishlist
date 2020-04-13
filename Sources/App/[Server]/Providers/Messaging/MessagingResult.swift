// MARK: MessagingResult

public enum MessagingResult: CustomStringConvertible {

    case success(_ messaging: Messaging)
    case failure(_ messaging: Messaging, error: MessagingError)

    // MARK: CustomStringConvertible

    public var description: String {
        switch self {
        case let .success(messaging):
            return "success(\(messaging))"
        case let .failure(messaging, error):
            return "failure(\(messaging), error: \(error)"
        }
    }

}
