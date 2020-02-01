// MARK: LanguageTag

/// This type represents a language tag as of IETF BCP 47.
public struct LanguageTag: StringValue {

    /// Let me introduce to you: The tag itself.
    public let rawValue: String

    /// Creates an language tag using the specified string. No checks are made on the given
    /// string. It's completely up to the caller to ensure the validity of the language tag.
    public init(string: String) {
        self.rawValue = string
    }

}
