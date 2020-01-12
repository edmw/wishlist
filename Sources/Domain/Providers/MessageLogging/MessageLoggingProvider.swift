import Library

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

    /// Writes a log message.
    func message(
        _ message: LoggingMessage,
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
        _ message: LoggingMessage,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        var values = message.encodableValues
        values["__file"] = AnyEncodable(file)
        values["__function"] = AnyEncodable(function)
        values["__line"] = AnyEncodable(line)
        values["__column"] = AnyEncodable(column)

        let logmessage: String

        let jsonencoder = JSONEncoder()
        jsonencoder.outputFormatting = [.prettyPrinted]
        if let jsondata = try? jsonencoder.encode(values),
           let jsonstring = String(data: jsondata, encoding: .utf8)
        {
            logmessage = "JSON \(jsonstring)"
        }
        else {
            let string = String(describing: values)
            logmessage = "STRING \(string)"
        }

        let info = "\(message.label):\n\(logmessage)\n"
        log(info: info, file: file, function: function, line: line, column: column)
    }

}

// MARK: -

extension EventLoopFuture {

    func logMessage(
        _ root: LoggingMessageRoot,
        for subject: ((Expectation) -> Any)? = nil,
        using logging: MessageLoggingProvider,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.map(to: Expectation.self) { expectationValue in
            let log: Bool
            if let condition = condition {
                log = condition(expectationValue)
            }
            else {
                log = true
            }
            if log {
                let message = root.transform(subject?(expectationValue) ?? expectationValue)
                logging.message(message, file: file, function: function, line: line, column: column)
            }
            return expectationValue
        }
    }

}
