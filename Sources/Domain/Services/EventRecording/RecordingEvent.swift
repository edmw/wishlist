import Library

import Foundation

// MARK: LoggingMessage

typealias RecordingSubject = Any

public struct RecordingEvent {

    let kind: RecordingEventKind

    let subject: RecordingSubject

    var attributes: [String: Any] = [:]

    init(
        _ kind: RecordingEventKind,
        subject: LoggingSubject,
        attributes: [String: Any] = [:]
    ) {
        self.kind = kind
        self.subject = subject
        self.attributes = attributes
    }

    mutating func setAttribute(_ value: Any, for key: String) {
        attributes[key] = value
    }

}
