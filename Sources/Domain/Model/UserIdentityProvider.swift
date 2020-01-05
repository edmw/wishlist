import Foundation

/// This type represents an identity provider for a user used for authentication.
public struct UserIdentityProvider: StringValue {

    /// Let me introduce to you: The user identity provider itself.
    public let rawValue: String

    /// Creates a user identity provider using the specified string. No checks are made on the
    /// given string. It's completely up to the caller to ensure the validity of the user identity
    /// provider.
    public init(string: String) {
        self.rawValue = string
    }

}
