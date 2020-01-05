import Foundation
import NIO

// MARK: MessageLoggingProvider

public protocol MessageLoggingProvider {

    /// Writes a debug log message.
    func debug(_ string: String, file: String, function: String, line: UInt, column: UInt)
    /// Function for the implementer of this provider to write a debug log message.
    /// As a user use `debug()` instead. This indirection is needed for the #-literals to work.
    func log(debug string: String, file: String, function: String, line: UInt, column: UInt)

    /// Writes an info log message.
    func info(_ string: String, file: String, function: String, line: UInt, column: UInt)
    /// Function for the implementer of this provider to write an info log message.
    /// As a user use `info()` instead. This indirection is needed for the #-literals to work.
    func log(info string: String, file: String, function: String, line: UInt, column: UInt)

    /// Writes a warning log message.
    func warning(_ string: String, file: String, function: String, line: UInt, column: UInt)
    /// Function for the implementer of this provider to write a warning log message.
    /// As a user use `warning()` instead. This indirection is needed for the #-literals to work.
    func log(warning string: String, file: String, function: String, line: UInt, column: UInt)

    /// Writes an error log message.
    func error(_ string: String, file: String, function: String, line: UInt, column: UInt)
    /// Function for the implementer of this provider to write an error log message.
    /// As a user use `error()` instead. This indirection is needed for the #-literals to work.
    func log(error string: String, file: String, function: String, line: UInt, column: UInt)

    /// Writes a log message for a given subject with level info.
    func message(
        for subject: @autoclosure () -> Any,
        with message: String,
        file: String,
        function: String,
        line: UInt,
        column: UInt
    )

}

extension MessageLoggingProvider {

    public func debug(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        log(debug: string, file: file, function: function, line: line, column: column)
    }

    public func info(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        log(info: string, file: file, function: function, line: line, column: column)
    }

    public func warning(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        log(warning: string, file: file, function: function, line: line, column: column)
    }

    public func error(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        log(error: string, file: file, function: function, line: line, column: column)
    }

    public func message(
        for subject: @autoclosure () -> Any,
        with message: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        log(
            info: "\(String(describing: subject())) \(message)",
            file: file, function: function, line: line, column: column
        )
    }

}

// MARK: -

extension EventLoopFuture {

    /// Logs an info message together with a description of this future’s expectation.
    func logMessage(
        for subject: ((Expectation) -> Any)? = nil,
        _ message: String,
        using logging: MessageLoggingProvider,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.map(to: Expectation.self) { value in
            let log: Bool
            if let condition = condition {
                log = condition(value)
            }
            else {
                log = true
            }
            if log {
                logging.message(
                    for: subject?(value) ?? value,
                    with: message,
                    file: file, function: function, line: line, column: column
                )
            }
            return value
        }
    }

    func logMessage(
        for subject: Any,
        _ message: String,
        using logging: MessageLoggingProvider,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.logMessage(
            for: { _ in subject },
            message,
            using: logging,
            when: condition,
            file: file, function: function, line: line, column: column
        )
    }

}
