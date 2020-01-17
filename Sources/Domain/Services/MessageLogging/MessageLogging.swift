import Library

import Foundation

// MARK: MessageLogging

/// Service for message logging.
struct MessageLogging {

    let configuration: MessageLoggingConfiguration

    let provider: MessageLoggingProvider

    init(provider: MessageLoggingProvider) {
        self.configuration = provider.configuration
        self.provider = provider
    }

    /// Writes a debug log message.
    internal func debug(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        provider.log(debug: string, file: file, function: function, line: line, column: column)
    }

    /// Writes an info log message.
    internal func info(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        provider.log(info: string, file: file, function: function, line: line, column: column)
    }

    /// Writes a warning log message.
    internal func warning(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        provider.log(warning: string, file: file, function: function, line: line, column: column)
    }

    /// Writes an error log message.
    internal func error(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        provider.log(error: string, file: file, function: function, line: line, column: column)
    }

    /// Writes a logging message.
    internal func message(
        _ message: LoggingMessage,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let subject = message.subject
        let attributes = message.attributes

        var values = attributes.mapValues { value in self.encodable(from: value) }
        values[subject] = self.encodable(from: subject)
        values["__file"] = self.encodable(from: file)
        values["__function"] = self.encodable(from: function)
        values["__line"] = self.encodable(from: line)
        values["__column"] = self.encodable(from: column)

        let logmessage: String

        let jsonencoder = JSONEncoder(logging: configuration)
        jsonencoder.outputFormatting = [.prettyPrinted]
        jsonencoder.dateEncodingStrategy = .iso8601
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
        provider.log(info: info, file: file, function: function, line: line, column: column)
    }

    private func encodable(from any: Any) -> AnyEncodable {
        switch any {
        case let loggable as Loggable:
            return .init(configuration.production ? loggable.loggable : loggable.debugLoggable)
        case let encodable as Encodable:
            return .init(encodable)
        case let array as [Any]:
            return .init(array.map { any in String(describing: any) })
        default:
            return .init(String(describing: any))
        }
    }

}

extension Dictionary where Key == String, Value == AnyEncodable {

    subscript(any: Any) -> AnyEncodable? {
        get { return self[String(describing: type(of: any))] }
        set { self[String(describing: type(of: any))] = newValue }
    }

}
