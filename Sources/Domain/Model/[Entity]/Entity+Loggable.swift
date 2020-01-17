import Foundation

/// Default implementation of `Loggable` for types conforming to `Entity`.
/// Must confirm to `Codable` and `CustomStringConvertible`, also.
extension Loggable where Self: Entity & Codable & CustomStringConvertible {

    public var loggable: Encodable {
        return description
    }

    public var debugLoggable: Encodable {
        return self
    }

}
