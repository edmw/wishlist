// MARK: Title

/// This type represents a title.
public struct Title: StringValue {

    /// Let me introduce to you: The title itself.
    public let rawValue: String

    /// Creates a title using the specified string. No checks are made on the given string.
    public init(string: String) {
        self.rawValue = string
    }

}
