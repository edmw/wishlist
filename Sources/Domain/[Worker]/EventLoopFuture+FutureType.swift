import Foundation
import NIO

extension EventLoopFuture: FutureType {

    /// Defines an alias for the expectation type T of an eventloop future.
    typealias Expectation = T

}
