import Library

import Foundation

// MARK: EventRecording

/// Service for event recording.
struct EventRecording {

    let provider: EventRecordingProvider

    internal func event(
        _ string: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        provider.record(string, file: file, function: function, line: line, column: column)
    }

    internal func event(
        _ event: RecordingEvent,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let kind = event.kind
        let subject = event.subject
        let attributes = event.attributes

        var values = [String: [String: AnyEncodable]]()
        values["event"] = ["kind": AnyEncodable(String(describing: kind))]
        values["subject"] = [String(describing: type(of: subject)): self.encodable(from: subject)]
        values["attributes"] = attributes.mapValues { value in self.encodable(from: value) }

        let recordingEvent: String

        let jsonencoder = JSONEncoder()
        jsonencoder.outputFormatting = [.prettyPrinted]
        jsonencoder.dateEncodingStrategy = .iso8601
        if let jsondata = try? jsonencoder.encode(values),
           let jsonstring = String(data: jsondata, encoding: .utf8)
        {
            recordingEvent = "JSON \(jsonstring)"
        }
        else {
            let string = String(describing: values)
            recordingEvent = "STRING \(string)"
        }

        let text = "EVENT:\n\(recordingEvent)\n"
        provider.record(text, file: file, function: function, line: line, column: column)
    }

    private func encodable(from any: Any) -> AnyEncodable {
        switch any {
        case let encodable as Encodable:
            return .init(encodable)
        case let array as [Any]:
            return .init(array.map { any in String(describing: any) })
        default:
            return .init(String(describing: any))
        }
    }

}
