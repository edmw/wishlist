/// Type which represents a pushover user.
/// A pushover user is composed of a user key.
/// Note: No validation is done!
public struct PushoverUser: ExpressibleByStringLiteral, CustomStringConvertible {

    let key: String

    public init(key: String) {
        self.key = key
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
