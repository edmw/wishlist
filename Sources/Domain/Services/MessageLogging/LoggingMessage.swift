import Library

import Foundation

// MARK: LoggingMessage

typealias LoggingSubject = Any

/// Message for structured logging. A logging message contains a label, a subject to be logged,
/// additional attributes to be included in the log and its log level.
/// Log level can be one of `debug`, `info`, `warning` and `error`.
public struct LoggingMessage {

    let label: String

    let subject: LoggingSubject

    var attributes: [String: Any] = [:]

    enum Level {
        case debug
        case info
        case warning
        case error
    }

    let level: Level

    init(
        label: String,
        subject: LoggingSubject,
        attributes: [String: Any] = [:],
        level: Level = .info
    ) {
        self.label = label
        self.subject = subject
        self.attributes = attributes
        self.level = level
    }

    init(debug label: String, subject: LoggingSubject, attributes: [String: Any] = [:]) {
        self.init(label: label, subject: subject, attributes: attributes, level: .debug)
    }

    init(info label: String, subject: LoggingSubject, attributes: [String: Any] = [:]) {
        self.init(label: label, subject: subject, attributes: attributes, level: .info)
    }

    init(warn label: String, subject: LoggingSubject, attributes: [String: Any] = [:]) {
        self.init(label: label, subject: subject, attributes: attributes, level: .warning)
    }

    init(error label: String, subject: LoggingSubject, attributes: [String: Any] = [:]) {
        self.init(label: label, subject: subject, attributes: attributes, level: .error)
    }

    /// Note: Fails fatally, if there is an attribute with a duplicate label. This is on purpose.
    init(
        label: String,
        subject: Loggable,
        loggables: [Loggable?],
        level: Level = .info
    ) {
        self.label = label
        self.subject = subject
        self.attributes = Dictionary(
            uniqueKeysWithValues: loggables.compactMap { $0 }.map { ($0.loggableLabel, $0) }
        )
        self.level = level
    }

    init(debug label: String, subject: Loggable, loggables: [Loggable?]) {
        self.init(label: label, subject: subject, loggables: loggables, level: .debug)
    }

    init(info label: String, subject: Loggable, loggables: [Loggable?]) {
        self.init(label: label, subject: subject, loggables: loggables, level: .info)
    }

    init(warn label: String, subject: Loggable, loggables: [Loggable?]) {
        self.init(label: label, subject: subject, loggables: loggables, level: .warning)
    }

    init(error label: String, subject: Loggable, loggables: [Loggable?]) {
        self.init(label: label, subject: subject, loggables: loggables, level: .error)
    }

    mutating func setAttribute(_ value: Any, for key: String) {
        attributes[key] = value
    }

}
