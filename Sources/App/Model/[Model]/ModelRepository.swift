import Vapor

import Foundation

protocol ModelRepository: ServiceType {

    /// Creates a new, succeeded `Future` from the db worker's event loop with a `Void` value.
    func future() -> Future<Void>
    /// Creates a new, succeeded `Future` from the db worker's event loop.
    func future<M>(_ value: M) -> Future<M>
    /// Creates a new, failed `Future` from the db worker's event loop.
    func future<M>(error: Error) -> Future<M>

}
