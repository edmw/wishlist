import Vapor

extension EventLoopFuture where Expectation: OptionalType {

    /// returns an error if the future’s result optional is not nil
    public func `nil`(or error: @autoclosure @escaping () -> Error) -> EventLoopFuture<Void> {
        return map(to: Void.self) { optional in
            guard optional.wrapped == nil else {
                throw error()
            }
            return ()
        }
    }

    /// returns true if the future’s result optional is nil, false otherwise
    public func `nil`() -> EventLoopFuture<Bool> {
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
    public func `null`() -> EventLoopFuture<Bool> {
        return map { result in
            result == 0
        }
    }

    /// Checks an integer value to be lower or equal than the specified maximum.
    /// Otherwise, the supplied error will be thrown instead.
    /// - Parameter maximum: maximum permitted value
    /// - Parameter error: `Error` to throw if the value is greater than the specified maximum.
    ///     This is captured with `@autoclosure` to avoid intiailize the `Error` unless needed.
    func max(_ maximum: Int, or error: @autoclosure @escaping () -> Error) -> Future<Expectation> {
        return map(to: Expectation.self) { value in
            guard value <= maximum else {
                throw error()
            }
            return value
        }
    }

    /// Checks an integer value to be greater or equal than the specified minimum.
    /// Otherwise, the supplied error will be thrown instead.
    /// - Parameter minimum: minimum permitted value
    /// - Parameter error: `Error` to throw if the value is loweer than the specified minimum.
    ///     This is captured with `@autoclosure` to avoid intiailize the `Error` unless needed.
    func min(_ minimum: Int, or error: @autoclosure @escaping () -> Error) -> Future<Expectation> {
        return map(to: Expectation.self) { value in
            guard value >= minimum else {
                throw error()
            }
            return value
        }
    }

}
