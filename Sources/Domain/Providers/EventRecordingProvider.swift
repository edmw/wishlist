import Foundation
import NIO

// MARK: EventRecordingProvider

public protocol EventRecordingProvider {

    /// Function for the implementer of this provider to emit an event.
    /// Internally use `EventRecording.event()` instead. This indirection is needed for
    /// the #-literals to work.
    func record(_ string: String, file: String, function: String, line: UInt, column: UInt)

}
