import Foundation
import NIO

extension EventLoopFuture {

    /// Transforms the specified error to another error.
    /// - Parameter error: Error type to transform.
    /// - Parameter newError: Error type to use instead.
    func transformError<E: Error>(when error: E, then newError: @autoclosure @escaping () -> Error)
        -> EventLoopFuture<Expectation>
    {
        return self.thenIfError { inputError in
            if inputError is E {
                return self.eventLoop.newFailedFuture(error: newError())
            }
            return self.eventLoop.newFailedFuture(error: inputError)
        }
    }

}
