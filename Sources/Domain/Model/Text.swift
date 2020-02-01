// MARK: Text

/// This type represents a text.
public struct Text: StringValue {

    /// Let me introduce to you: The text itself.
    public let rawValue: String

    /// Creates a text using the specified string. No checks are made on the given string.
    public init(string: String) {
        self.rawValue = string
    }

}
