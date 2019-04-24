import Vapor

import Foundation

/// This is a logger coordinator which forwards each log message to every configured target logger.
class MultiLogger: Logger, Service {

    var targets = [Logger]()

    init() {
    }

    init(target logger: Logger) {
        self.targets.append(logger)
    }

    init(targets loggers: [Logger]) {
        self.targets.append(contentsOf: loggers)
    }

    func append(target logger: Logger) {
        self.targets.append(logger)
    }

    func append(targets loggers: [Logger]) {
        self.targets.append(contentsOf: loggers)
    }

    func log(
        _ string: String,
        at level: LogLevel,
        file: String,
        function: String,
        line: UInt,
        column: UInt
    ) {
        targets.forEach { logger in
            logger.log(
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
