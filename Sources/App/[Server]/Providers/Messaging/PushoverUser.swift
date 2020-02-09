/// Type which represents a pushover user.
/// A pushover user is composed of a user key.
/// Note: No validation is done!
public struct PushoverUser: ExpressibleByStringLiteral, CustomStringConvertible {

    let key: String

    /// Constructs a pushover user with the given pushover user key.
    public init(_ string: String) {
        self.key = string
    }

    public init(stringLiteral value: String) {
        self.key = value
    }

    public var description: String {
        return key
    }

}

extension Sequence where Iterator.Element == PushoverUser {

    func joined(seperator: String = ",") -> String {
        return self.map { "\($0)" }.joined(separator: seperator)
    }

}
