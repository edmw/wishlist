import Foundation

// MARK: Loggable

/// Types conforming to `Loggable` provide different views to self for structured logging. First,
/// a view for release builds and production mode and second, for debugging purposes. The former
/// logging absolute necessary and legally permitted information, only, the latter logging a lot
/// more to facilitate debugging.
public protocol Loggable {

    /// Label for structured debugging entries.
    var loggableLabel: String { get }

    /// View on self for production structured logging.
    /// Note: make this restricted, i.e. GDPR compliant
    var loggable: Encodable { get }

    /// View on self for debugging structured logging.
    /// Note: make this extensive
    var debugLoggable: Encodable { get }

}

/// Default implementation of `Loggable` for types conforming to `Codable`
/// and `CustomStringConvertible`.
extension Loggable where Self: Codable & CustomStringConvertible {

    public var loggableLabel: String {
        return String(describing: type(of: self))
    }

    public var loggable: Encodable {
        return description
    }

    public var debugLoggable: Encodable {
        return self
    }

}
