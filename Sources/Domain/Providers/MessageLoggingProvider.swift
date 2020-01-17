import Foundation

// MARK: MessageLoggingProvider

public protocol MessageLoggingProvider {

    var configuration: MessageLoggingConfiguration { get }

    /// Function for the implementer of this provider to write a debug log message.
    /// Internally use `MessageLogging.debug()` instead. This indirection is needed for
    /// the #-literals to work.
    func log(debug string: String, file: String, function: String, line: UInt, column: UInt)

    /// Function for the implementer of this provider to write an info log message.
    /// Internally use `MessageLogging.info()` instead. This indirection is needed for
    /// the #-literals to work.
    func log(info string: String, file: String, function: String, line: UInt, column: UInt)

    /// Function for the implementer of this provider to write a warning log message.
    /// Internally use `MessageLogging.warning()` instead. This indirection is needed for
    /// the #-literals to work.
    func log(warning string: String, file: String, function: String, line: UInt, column: UInt)

    /// Function for the implementer of this provider to write an error log message.
    /// Internally use `MessageLogging.error()` instead. This indirection is needed for
    /// the #-literals to work.
    func log(error string: String, file: String, function: String, line: UInt, column: UInt)

}
