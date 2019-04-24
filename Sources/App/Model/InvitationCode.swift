import Vapor

import Foundation

/// This type represents an invitation code. An invitation code is mostly a simple string
/// which should be hard to guess and unique amongst the set of all invitation codes.
/// Additionally, to ease handling by humans an invitation code should be as short in length as
/// possible and consisting of alphanumeric characters only. Best, if only characters are used
/// which can not be easily mistaken by humans (which this implementation doesn't do).
///
/// This type is an example on how a simple type (string) can be made into a value type.
struct InvitationCode: RawRepresentable,
    ExpressibleByStringLiteral,
    CustomStringConvertible,
    Codable,
    Hashable,
    Equatable
{

    /// Let me introduce to you: The code itself.
    let rawValue: String

    /// Generates a new invitation code. This uses UUID as base for the codes which isn't
    /// optimal because UUIDs are designed to be unique not to be random. Nevertheless, we will
    /// accept the risk of some smart people guessing our invitation codes.
    init() throws {
        // get a new uuid, convert it to a base62 string and discard every 3rd character,
        // this should be unique enough and reduces the length of the code significally
        self.rawValue = try String(
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
    /// are to long anyway.
    init(string: String) {
        precondition(string.count <= 32)
        self.rawValue = string
    }

    // MARK: RawRepresentable

    init?(rawValue: String) {
        self.init(string: rawValue)
    }

    // MARK: ExpressibleByStringLiteral

    init(stringLiteral value: String) {
        self.init(string: value)
    }

    // MARK: CustomStringConvertible

    var description: String {
        return rawValue
    }

    // MARK: Codable

    /// Decodes the invitation code from a single value aka string.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(string: value)
    }

    /// Encodes the invitation code into a single value aka string.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

}
