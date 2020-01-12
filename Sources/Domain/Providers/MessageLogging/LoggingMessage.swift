import Library

import Foundation

// MARK: LoggingMessage

typealias LoggingSubject = Any

public struct LoggingMessage {

    enum Level {
        case debug
        case info
        case warning
        case error
    }

    let level: Level

    let label: String

    let subject: LoggingSubject

    var attributes: [String: Any] = [:]

    var encodableValues: [String: AnyEncodable] {
        var values = attributes.mapValues { value in AnyEncodable(from: value) }
        values[subject] = AnyEncodable(from: subject)
        return values
    }

    init(
        level: Level = .info,
        label: String,
        subject: LoggingSubject,
        attributes: [Loggable?] = []
    ) {
        self.level = level
        self.label = label
        self.subject = subject
        self.attributes = Dictionary(
            grouping: attributes.compactMap { $0 },
            by: { $0?.loggableLabel ?? "null" }
        )
    }

    init(debug label: String, subject: LoggingSubject, attributes: [Loggable?] = []) {
        self.init(level: .debug, label: label, subject: subject, attributes: attributes)
    }

    init(info label: String, subject: LoggingSubject, attributes: [Loggable?] = []) {
        self.init(level: .info, label: label, subject: subject, attributes: attributes)
    }

    init(warn label: String, subject: LoggingSubject, attributes: [Loggable?] = []) {
        self.init(level: .warning, label: label, subject: subject, attributes: attributes)
    }

    init(error label: String, subject: LoggingSubject, attributes: [Loggable?] = []) {
        self.init(level: .error, label: label, subject: subject, attributes: attributes)
    }

    mutating func setAttribute(_ value: Any, for key: String) {
        attributes[key] = value
    }

}

extension AnyEncodable {

    fileprivate init(from any: Any) {
        if let loggable = any as? Loggable {
            self.init(loggable.debugLoggable)
        }
        else if let encodable = any as? Encodable {
            self.init(encodable)
        }
        else {
            self.init(String(describing: any))
        }
    }

}

extension Dictionary where Key == String, Value == AnyEncodable {

    fileprivate subscript(any: Any) -> AnyEncodable? {
        get { return self[String(describing: type(of: any))] }
        set { self[String(describing: type(of: any))] = newValue }
    }

}
