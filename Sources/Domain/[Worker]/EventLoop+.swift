import Foundation
import NIO

// Domain and Vapor 3 are using the NIO version 1.
// These are some aliases which will be renamed in NIO version 2.
extension EventLoop {

    /// Creates a new, succeeded `EventLoopFuture` from the event loop with a `Void` value.
    public func makeSucceededFuture() -> EventLoopFuture<Void> {
        return self.newSucceededFuture(result: ())
    }

    /// Creates a new, succeeded `EventLoopFuture` from the event loop.
    public func makeSucceededFuture<T>(_ value: T) -> EventLoopFuture<T> {
        return self.newSucceededFuture(result: value)
    }

    /// Creates a new, failed `EventLoopFuture` from the event loop.
    public func makeFailedFuture<T>(error: Error) -> EventLoopFuture<T> {
        return self.newFailedFuture(error: error)
    }

}
