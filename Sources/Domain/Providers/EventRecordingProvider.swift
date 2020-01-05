import Foundation
import NIO

// MARK: EventRecordingProvider

public protocol EventRecordingProvider {

    /// Emits an event.
    func event(_ string: String, file: String, function: String, line: UInt, column: UInt)
    /// Function for the implementer of this provider to emit an event.
    /// As a user use `event()` instead. This indirection is needed for the #-literals to work.
    func record(_ string: String, file: String, function: String, line: UInt, column: UInt)

}

extension EventRecordingProvider {

    public func event(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        record(string, file: file, function: function, line: line, column: column)
    }

}

// MARK: -

extension EventLoopFuture {

    /// Logs a message together with a description of this future’s expectation.
    func recordEvent(
        for subject: ((Expectation) -> Any)? = nil,
        _ message: String,
        using recording: EventRecordingProvider,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.map(to: Expectation.self) { value in
            let log: Bool
            if let condition = condition {
                log = condition(value)
            }
            else {
                log = true
            }
            if log {
                let description: String
                if let subject = subject {
                    description = String(describing: subject(value))
                }
                else {
                    description = String(describing: value)
                }
                recording.event(
                    "\(description) \(message)",
                    file: file,
                    function: function,
                    line: line,
                    column: column
                )
            }
            return value
        }
    }

    func recordEvent(
        for subject: Any,
        _ message: String,
        using recording: EventRecordingProvider,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.recordEvent(
            for: { _ in subject },
            message,
            using: recording,
            when: condition,
            file: file, function: function, line: line, column: column
        )
    }

}
