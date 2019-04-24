import Vapor

import Foundation

/// This is a logger processor which filters the log messages using the specified closure.
/// Forwards any log message not filtered out to the specified target logger.
///
/// Configuration:
/// - Filter closure which will be called with the log message string and level and should
/// return `true` if the message is to be kept, or `false` if it should be discarded.
/// - Target logger
class FilteredLogger: Logger, Service {

    let target: Logger

    let filter: (String, LogLevel) -> Bool

    init(target logger: Logger, _ filter: @escaping (String, LogLevel) -> Bool) {
        self.target = logger
        self.filter = filter
    }

    func log(
        _ string: String,
        at level: LogLevel,
        file: String,
        function: String,
        line: UInt,
        column: UInt
    ) {
        // call the filter closure and forward or discard log message
        if filter(string, level) {
            target.log(
                string,
                at: level,
                file: file,
                function: function,
                line: line,
                column: column
            )
        }
    }

}
