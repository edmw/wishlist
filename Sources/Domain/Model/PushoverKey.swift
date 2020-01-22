// MARK: PushoverKey

/// This type represents an pushover key.
public struct PushoverKey: SensitiveStringValue {

    /// Let me introduce to you: The key itself.
    public let rawValue: String

    /// Creates an pushover key using the specified string. No checks are made on the given
    /// string. It's completely up to the caller to ensure the validity of the pushover key.
    public init(string: String) {
        self.rawValue = string
    }

}
