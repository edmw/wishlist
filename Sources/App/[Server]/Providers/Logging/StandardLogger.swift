import Vapor

import Foundation

/// This is a logger which provides different loggers for technical log events, application log
/// events and business log events. Accordingly adds a tag to every logger. Respects the specified
/// minimum log level.
/// Note(1): For now the loggers output is fixed to use `ConsoleLogger`.
/// Note(2): Every log message sent directly to this logger will be emitted to technical logger.
class StandardLogger: Logger, Service {

    let technical: Logger
    let application: Logger
    let business: Logger

    private var multi: MultiLogger

    init(
        technicalLogLevel: LogLevel,
        applicationLogLevel: LogLevel,
        businessLogLevel: LogLevel
    ) {
        self.multi = MultiLogger()
        let technical = TaggedLogger(target: multi, tag: "TEC")
        let application = TaggedLogger(target: multi, tag: "APP")
        let business = TaggedLogger(target: multi, tag: "BUS")
        let technicalTarget = FilteredLogger(
            target: ConsoleLogger(symbols: .hearts)
        ) { string, level -> Bool in
            return level >= technicalLogLevel && string.starts(with: technical.tag)
        }
        let applicationTarget = FilteredLogger(
            target: ConsoleLogger(symbols: .hands)
        ) { string, level -> Bool in
            return level >= applicationLogLevel && string.starts(with: application.tag)
        }
        let businessTarget = FilteredLogger(
            target: ConsoleLogger(symbols: .books)
        ) { string, level -> Bool in
            return level >= businessLogLevel && string.starts(with: business.tag)
        }
        multi.append(
            targets: [technicalTarget, applicationTarget, businessTarget]
        )
        self.technical = technical
        self.application = application
        self.business = business
    }

    convenience init(
        level: LogLevel = .error
    ) {
        self.init(
            technicalLogLevel: level,
            applicationLogLevel: level,
            businessLogLevel: level
        )
    }

    func log(
        _ string: String,
        at level: LogLevel,
        file: String,
        function: String,
        line: UInt,
        column: UInt
    ) {
        technical.log(string, at: level, file: file, function: function, line: line, column: column)
    }

}
