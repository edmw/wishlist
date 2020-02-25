import Vapor

import Foundation

/// This is a basic logger which filters all log messages to be of the same or higher level than
/// the specified log level.
/// 
/// Optionally adds a tag to every log message.
/// Note: For now the logger output is fixed to use `ConsoleLogger`.
class BasicLogger: Logger, Service, CustomStringConvertible {

    let logLevel: LogLevel

    private var logger: Logger

    init(
        level logLevel: LogLevel = .error,
        tag: String? = nil
    ) {
        self.logLevel = logLevel

        let target = ConsoleLogger(symbols: .weather)
        let logger = FilteredLogger(target: target) { _, level -> Bool in
            level >= logLevel
        }

        if let tag = tag {
            self.logger = TaggedLogger(target: logger, tag: tag)
        }
        else {
            self.logger = logger
        }
    }

    func log(
        _ string: String,
        at level: LogLevel,
        file: String,
        function: String,
        line: UInt,
        column: UInt
    ) {
        logger.log(string, at: logLevel, file: file, function: function, line: line, column: column)
    }

    // MARK: CustomStringConvertible

    var description: String {
        return String(describing: type(of: self)) + "(Level=\(logLevel))"
    }

}
