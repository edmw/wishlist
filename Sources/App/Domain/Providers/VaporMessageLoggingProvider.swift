import Domain

import Vapor

// MARK: VaporMessageLoggingProvider

/// Adapter for the domain layers `MessageLoggingProvider` to be used with Vapor.
///
/// This delegates the work to the web app‘s message logging framework.
struct VaporMessageLoggingProvider: MessageLoggingProvider {

    let logger: Logger

    init(with logger: Logger) {
        self.logger = logger
    }

    func log(debug string: String, file: String, function: String, line: UInt, column: UInt) {
        self.logger.debug(string, file: file, function: function, line: line, column: column)
    }

    func log(info string: String, file: String, function: String, line: UInt, column: UInt) {
        self.logger.info(string, file: file, function: function, line: line, column: column)
    }

    func log(warning string: String, file: String, function: String, line: UInt, column: UInt) {
        self.logger.warning(string, file: file, function: function, line: line, column: column)
    }

    func log(error string: String, file: String, function: String, line: UInt, column: UInt) {
        self.logger.error(string, file: file, function: function, line: line, column: column)
    }

}
