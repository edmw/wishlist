import Library

import Foundation

/// This type represents an invitation code. An invitation code is mostly a simple string
/// which should be hard to guess and unique amongst the set of all invitation codes.
/// Additionally, to ease handling by humans an invitation code should be as short in length as
/// possible and consisting of alphanumeric characters only. Best, if only characters are used
/// which can not be easily mistaken by humans (which this implementation doesn't do).
public struct InvitationCode: Encodable {

    /// Let me introduce to you: The code itself.
    public var rawValue: String

    /// Generates a new invitation code. This uses UUID as base for the codes which isn't
    /// optimal because UUIDs are designed to be unique not to be random. Nevertheless, we will
    /// accept the risk of some smart people guessing our invitation codes.
    public init() {
        // get a new uuid, convert it to a base62 string and discard every 3rd character,
        // this should be unique enough and reduces the length of the code significally
        self.rawValue = String(
            UUID()
            .convertedToBase62String()
            .enumerated()
            .compactMap { offset, character in offset % 3 == 1 ? nil : character }
        )
    }

    /// Creates an invitation code using the specified string. No checks are made on the given
    /// string. It's completely up to the caller to ensure the qualities of a good code.
    /// This will fail if the given string exceeds 32 characters in length. This is because the
    /// database extension will use that maximum length for the database field and 32 characters
    /// are too long anyway.
    public init(string: String) {
        precondition(string.count <= 32)
        self.rawValue = string
    }

}
