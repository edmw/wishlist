/// Type which represents an email address.
/// An email address is composed of an internet identifier and a display name.
/// Note: No validation is done!
public struct EmailAddress: ExpressibleByStringLiteral, CustomStringConvertible {

    let identifier: String
    let name: String?

    /// Constructs an email address with the given email address identifier and name.
    public init(_ string: String, name: String? = nil) {
        self.identifier = string
        self.name = name
    }

    public init(stringLiteral value: String) {
        self.identifier = value
        self.name = nil
    }

    public var description: String {
        if let name = name {
            return "\(name) <\(identifier)>"
        }
        else {
            return "\(identifier)"
        }
    }

}

extension Sequence where Iterator.Element == EmailAddress {

    func joined(seperator: String) -> String {
        return self.map { "\($0)" }.joined(separator: seperator)
    }

}
