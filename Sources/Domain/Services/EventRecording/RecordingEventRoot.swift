import Foundation

// MARK: RecordingEventRoot

/// Factory to create a recording event with an subject of type T.
struct RecordingEventRoot<T> {

    /// Closure to create a recording event with an subject of type T.
    var transform: (T) -> RecordingEvent

    /// Initialise this factory with the given closure to create a recording event with an subject
    /// of type T.
    ///
    /// - Parameter transform: Closure to create a recording event.
    init(_ transform: @escaping (T) -> RecordingEvent) {
        self.transform = transform
    }

}
