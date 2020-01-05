import Foundation

extension ValueValidator where T: OptionalValue {

    static var `nil`: ValueValidator<T.WrappedValue?> {
        return NilValidator(T.WrappedValue.self).validator()
    }

}

private struct NilValidator<T>: ValueValidatorType {
    typealias ValidationData = T?

    init(_ type: T.Type) {}

    func validate(_ data: T?) throws {
        if data != nil {
            throw ValueValidationError("is not nil")
        }
    }

    var validatorReadable: String {
        return "nil"
    }

}
