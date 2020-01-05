import Foundation
import NIO

extension EventLoopFuture where Expectation: OptionalType {

    /// Unwraps an `Optional` value contained inside a Future's expectation.
    /// If the optional resolves to `nil`, the supplied error will be thrown instead.
    /// - parameters:
    ///     - error: `Error` to throw if the value is `nil`. This is captured with `@autoclosure`
    ///              to avoid intiailize the `Error` unless needed.
    func unwrap(or error: @autoclosure @escaping () -> Error)
        -> EventLoopFuture<Expectation.WrappedType>
    {
        return thenThrowing { optional in
            guard let wrapped = optional.wrapped else {
                throw error()
            }
            return wrapped
        }
    }

}
