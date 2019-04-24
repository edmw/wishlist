import Vapor

extension Future where Expectation: OptionalType {

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

    public func `nil`() -> Future<Bool> {
        return map { optional in
            optional.wrapped == nil
        }
    }

}
