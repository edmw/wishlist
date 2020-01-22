// MARK: UserIdentity

/// This type represents an identity for a user used for authentication. This unique per identity
/// provider.
public struct UserIdentity: StringValue {

    /// Let me introduce to you: The user identity itself.
    public let rawValue: String

    /// Creates a user identity using the specified string. No checks are made on the given
    /// string. It's completely up to the caller to ensure the validity of the user identity.
    public init(string: String) {
        self.rawValue = string
    }

}
