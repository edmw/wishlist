import DomainModel

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

extension Loggable {

    /// Default implementation for a loggable‘s label.
    ///
    /// It is important to note that a logging message must contain loggables with distinct label‘s
    /// only. Otherwise logging will fail fatally.
    public var loggableLabel: String {
        return String(describing: type(of: self))
    }

}

extension Loggable where Self: StringValue {

    /// Default implementation for the view on a `StringValue` for production logging.
    ///
    /// Note: String values do not have different values for production versus development logging.
    /// If there is need for different logging, this default implementation should be overwritten
    /// on a concrete type.
    public var loggable: Encodable {
        return self
    }

    /// Default implementation for the view on a `StringValue` for development logging.
    ///
    /// Note: String values do not have different values for production versus development logging.
    /// If there is need for different logging, this default implementation should be overwritten
    /// on a concrete type.
    public var debugLoggable: Encodable {
        return self
    }

}

extension Loggable where Self: Identifier {

    /// Default implementation for the view on an `Identifier` for production logging.
    ///
    /// Note: Identifiers do not have different values for production versus development logging.
    /// If there is need for different logging, this default implementation should be overwritten
    /// on a concrete type.
    public var loggable: Encodable {
        return self
    }

    /// Default implementation for the view on an `Identifier` for development logging.
    ///
    /// Note: Identifiers do not have different values for production versus development logging.
    /// If there is need for different logging, this default implementation should be overwritten
    /// on a concrete type.
    public var debugLoggable: Encodable {
        return self
    }

}
