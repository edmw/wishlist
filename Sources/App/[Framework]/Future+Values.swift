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

}
