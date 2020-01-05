import Foundation
import NIO

extension EventLoopFuture {

    /// Maps the current future to contain the new type. Errors are carried over, successful
    /// results are transformed into the given instance.
    func transform<T>(
        to instance: @escaping @autoclosure () -> T
    ) -> EventLoopFuture<T> {
        return self.map(to: T.self) { _ in instance() }
    }

    /// Maps the current future to contain the new type. Errors are carried over, successful
    /// results are transformed into the given instance.
    func transform<T>(
        to future: EventLoopFuture<T>
    ) -> EventLoopFuture<T> {
        return self.flatMap(to: T.self) { _ in future }
    }

}
