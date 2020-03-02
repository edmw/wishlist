import Foundation
import NIO

extension EventLoopFuture {

    /// Maps an `EventLoopFuture` to an `EventLoopFuture` of a different type.
    func map<T>(
        to type: T.Type = T.self,
        _ callback: @escaping (Expectation) throws -> T
    ) -> EventLoopFuture<T> {
        return self.thenThrowing(callback)
    }

    /// Maps an `EventLoopFuture` to an `EventLoopFuture` of a different type.
    func flatMap<T>(
        to type: T.Type = T.self,
        _ callback: @escaping (Expectation) throws -> EventLoopFuture<T>
    ) -> EventLoopFuture<T> {
        return self.then { input in
            do {
                return try callback(input)
            } catch {
                return self.eventLoop.newFailedFuture(error: error)
            }
        }
    }

    /// Calls the supplied closure if the chained EventLoopFuture resolves to an Error.
    func catchMap(
        _ callback: @escaping (Error) throws -> (Expectation)
    ) -> EventLoopFuture<Expectation> {
        return self.thenIfErrorThrowing(callback)
    }

    /// Calls the supplied closure if the chained EventLoopFuture resolves to an Error.
    func catchFlatMap(
        _ callback: @escaping (Error) throws -> (EventLoopFuture<Expectation>)
    ) -> EventLoopFuture<Expectation> {
        return self.thenIfError { inputError in
            do {
                return try callback(inputError)
            }
            catch {
                return self.eventLoop.newFailedFuture(error: error)
            }
        }
    }

}
