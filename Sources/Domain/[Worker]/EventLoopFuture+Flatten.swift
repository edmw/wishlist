import Foundation
import NIO

extension Collection {

    /// Flattens an array of futures into a future with an array of results.
    /// - Note: the order of the results will match the order of the futures in the input array.
    public func flatten<T>(
        on worker: EventLoop
    ) -> EventLoopFuture<[T]> where Element == EventLoopFuture<T> {
        return EventLoopFuture.whenAll(Array(self), eventLoop: worker)
    }

}
