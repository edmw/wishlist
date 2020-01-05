import Vapor

import Foundation

extension EventLoopFuture where Expectation: OptionalType {

    /// returns an error if the future’s result optional is not nil
    func `nil`(or error: @autoclosure @escaping () -> Error) -> EventLoopFuture<Void> {
        return map(to: Void.self) { optional in
            guard optional.wrapped == nil else {
                throw error()
            }
            return ()
        }
    }

    /// returns true if the future’s result optional is nil, false otherwise
    func `nil`() -> EventLoopFuture<Bool> {
        return map { optional in
            optional.wrapped == nil
        }
    }

}

extension EventLoopFuture where Expectation == Int {

    /// returns an error if the future’s result integer is not null
    func `null`(or error: @autoclosure @escaping () -> Error) -> EventLoopFuture<Void> {
        return map(to: Void.self) { result in
            guard result == 0 else {
                throw error()
            }
            return ()
        }
    }

    /// returns true if the future’s result integer is null, false otherwise
    func `null`() -> EventLoopFuture<Bool> {
        return map { result in
            result == 0
        }
    }

    /// Checks an integer value is equal to the specified value.
    /// Otherwise, the supplied error will be thrown.
    /// - Parameter value: value to compare with
    /// - Parameter error: `Error` to throw if the value is not equal to the specified value.
    ///     This is captured with `@autoclosure` to avoid intiailize the `Error` unless needed.
    func equals(
        _ value: Int,
        or error: @autoclosure @escaping () -> Error
    ) -> EventLoopFuture<Expectation> {
        return map(to: Expectation.self) { expectation in
            guard expectation == value else {
                throw error()
            }
            return expectation
        }
    }

    /// Checks an integer value to be lower or equal than the specified maximum.
    /// Otherwise, the supplied error will be thrown.
    /// - Parameter maximum: maximum permitted value
    /// - Parameter error: `Error` to throw if the value is greater than the specified maximum.
    ///     This is captured with `@autoclosure` to avoid intiailize the `Error` unless needed.
    func max(
        _ maximum: Int,
        or error: @autoclosure @escaping () -> Error
    ) -> EventLoopFuture<Expectation> {
        return map(to: Expectation.self) { expectation in
            guard expectation <= maximum else {
                throw error()
            }
            return expectation
        }
    }

    /// Checks an integer value to be greater or equal than the specified minimum.
    /// Otherwise, the supplied error will be thrown.
    /// - Parameter minimum: minimum permitted value
    /// - Parameter error: `Error` to throw if the value is loweer than the specified minimum.
    ///     This is captured with `@autoclosure` to avoid intiailize the `Error` unless needed.
    func min(
        _ minimum: Int,
        or error: @autoclosure @escaping () -> Error
    ) -> EventLoopFuture<Expectation> {
        return map(to: Expectation.self) { expectation in
            guard expectation >= minimum else {
                throw error()
            }
            return expectation
        }
    }

}
