import Foundation

// MARK: EventRecording

/// Service for event recording.
struct EventRecording {

    let provider: EventRecordingProvider

    func event(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        provider.record(string, file: file, function: function, line: line, column: column)
    }

}
