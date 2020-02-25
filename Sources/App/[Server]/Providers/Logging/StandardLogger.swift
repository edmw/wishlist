import Vapor

import Foundation

/// This is a logger which provides different loggers for technical log events, application log
/// events and business log events. Accordingly adds a tag to every logger. Respects the specified
/// minimum log level.
/// 
/// Note(1): For now the loggers output is fixed to use `ConsoleLogger`.
/// Note(2): Every log message sent directly to this logger will be emitted to technical logger.
class StandardLogger: Logger, Service, CustomStringConvertible, CustomDebugStringConvertible {

    let technical: Logger
    let application: Logger
    let business: Logger

    struct LoggerConfiguration {
        let tag: String
        let logLevel: LogLevel
        let logLevelSymbolSet: LogLevel.SymbolSet
    }

    private let technicalConfiguration: LoggerConfiguration
    private let applicationConfiguration: LoggerConfiguration
    private let businessConfiguration: LoggerConfiguration

    private var multi: MultiLogger

    init(
        technicalLogLevel: LogLevel,
        applicationLogLevel: LogLevel,
        businessLogLevel: LogLevel
    ) {
        let technicalTag = "[TEC]"
        let applicationTag = "[APP]"
        let businessTag = "[BUS]"

        self.technicalConfiguration
            = .init(tag: technicalTag, logLevel: technicalLogLevel, logLevelSymbolSet: .hearts)
        self.applicationConfiguration
            = .init(tag: applicationTag, logLevel: applicationLogLevel, logLevelSymbolSet: .hands)
        self.businessConfiguration
            = .init(tag: businessTag, logLevel: businessLogLevel, logLevelSymbolSet: .books)

        self.multi = MultiLogger()
        let technical = TaggedLogger(target: multi, tag: technicalConfiguration.tag)
        let application = TaggedLogger(target: multi, tag: applicationConfiguration.tag)
        let business = TaggedLogger(target: multi, tag: businessConfiguration.tag)
        let technicalTarget = FilteredLogger(
            target: ConsoleLogger(symbols: technicalConfiguration.logLevelSymbolSet)
        ) { string, level -> Bool in
            level >= technicalLogLevel && string.starts(with: technicalTag)
        }
        let applicationTarget = FilteredLogger(
            target: ConsoleLogger(symbols: applicationConfiguration.logLevelSymbolSet)
        ) { string, level -> Bool in
            level >= applicationLogLevel && string.starts(with: applicationTag)
        }
        let businessTarget = FilteredLogger(
            target: ConsoleLogger(symbols: businessConfiguration.logLevelSymbolSet)
        ) { string, level -> Bool in
            level >= businessLogLevel && string.starts(with: businessTag)
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

    // MARK: CustomStringConvertible

    var description: String {
        return String(describing: type(of: self)) + "(\(technical), \(application), \(business))"
    }

    // MARK: CustomDebugStringConvertible

    var debugDescription: String {
        var properties = [String]()
        properties.append("• Technical Logger = \(technicalConfiguration)")
        properties.append("• Application Logger = \(applicationConfiguration)")
        properties.append("• Business Logger = \(businessConfiguration)")
        return properties.joined(separator: "\n")
    }

}
