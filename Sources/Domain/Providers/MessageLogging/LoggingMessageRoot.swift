import Foundation

// MARK: LoggingMessageRoot

struct LoggingMessageRoot {

    var transform: (LoggingSubject) -> LoggingMessage

    init(_ transform: @escaping (LoggingSubject) -> LoggingMessage) {
        self.transform = transform
    }

}
