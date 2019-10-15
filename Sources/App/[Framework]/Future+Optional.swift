import Vapor

extension Future where Expectation: OptionalType {

    /// returns an error if the future’s result optional is nil
    public func `nil`(or error: @autoclosure @escaping () -> Error)
        -> Future<Expectation.WrappedType?>
    {
        return map { optional in
            if optional.wrapped != nil {
                throw error()
            }
            return optional.wrapped
        }
    }

    /// returns true if the future’s result optional is nil, false otherwise
    public func `nil`() -> Future<Bool> {
        return map { optional in
            optional.wrapped == nil
        }
    }

}
