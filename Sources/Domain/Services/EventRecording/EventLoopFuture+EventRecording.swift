import Foundation
import NIO

extension EventLoopFuture {

    /// Records a `RecordingEvent` using this future‘s value as recording subject to the specified
    /// `EventRecording`. The specified `RecordingEventRoot` is used to create the recording message
    /// from this future‘s value. This future‘s value is transformed into the `RecordingEvent`‘s
    /// subject by the specfied closure.
    /// - Parameter root: Factory to create a recording message from this future‘s value. This
    ///     future‘s value is processed through the specified closure `subject`, first and than
    ///     given to this factory to construct a recording message.
    /// - Parameter subject: Closure to transform this future‘s value into the recording messages‘
    ///     type. The result is passed to the specified factory to construct a recording message.
    /// - Parameter condition: Conditionally turn of recording by returning `false` from this
    ///     closure.
    /// - Parameter recording: Recording target to record into.
    /// - Parameter file: #file
    /// - Parameter function: #function
    /// - Parameter line: #line
    /// - Parameter column: #column
    func recordEvent<T>(
        _ root: RecordingEventRoot<T>,
        for subject: @escaping ((Expectation) -> T),
        when condition: ((Expectation) -> Bool)? = nil,
        using recording: EventRecording,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.map(to: Expectation.self) { expectationValue in
            let record: Bool
            if let condition = condition {
                record = condition(expectationValue)
            }
            else {
                record = true
            }
            if record {
                let event = root.transform(subject(expectationValue))
                recording.event(
                    event,
                    file: file,
                    function: function,
                    line: line,
                    column: column
                )
            }
            return expectationValue
        }
    }

    /// Records a `RecordingEvent` using this future‘s value as recording subject to the specified
    /// `EventRecording`. The specified `RecordingEventRoot` is used to create the recording message
    /// from this future‘s value.
    /// - Parameter root: Factory to create a recording message from this future‘s value.
    /// - Parameter condition: Conditionally turn of recording by returning `false` from this
    ///     closure.
    /// - Parameter recording: Recording target to record into.
    /// - Parameter file: #file
    /// - Parameter function: #function
    /// - Parameter line: #line
    /// - Parameter column: #column
    func recordEvent(
        _ root: RecordingEventRoot<Expectation>,
        when condition: ((Expectation) -> Bool)? = nil,
        using recording: EventRecording,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.flatMap(to: Expectation.self) { expectationValue in
            return self.recordEvent(
                root,
                for: { _ in expectationValue },
                when: condition,
                using: recording,
                file: file, function: function, line: line, column: column
            )
        }
    }

}
