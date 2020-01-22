// MARK: FileName

/// This type represents a file name.
public struct FileName: StringValue {

    /// Let me introduce to you: The key itself.
    public var rawValue: String

    /// Creates a file name using the specified string. No checks are made on the given
    /// string. It's completely up to the caller to ensure the validity of the file name.
    public init(string: String) {
        self.rawValue = string
    }

}
