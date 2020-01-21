import Foundation

/// This type represents an email specification as of RFC 5322 (section 3.4.1).
public struct EmailSpecification: Codable, Equatable {

    /// Let me introduce to you: The specification itself.
    public let rawValue: String

    /// Creates an email specification using the specified string. No checks are made on the given
    /// string. It's completely up to the caller to ensure the validity of the email specification.
    /// This will fail if the given string exceeds 254 characters in length. This is because an
    /// email address must not exceed this limit to be usable.
    public init(string: String) {
        precondition(string.count <= 254)
        self.rawValue = string
    }

}
