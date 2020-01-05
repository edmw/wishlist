import Foundation

internal func || <T>(lhs: ValueValidator<T?>, rhs: ValueValidator<T>) -> ValueValidator<T?> {
    return lhs || NilIgnoringValidator(rhs).validator()
}

internal func || <T>(lhs: ValueValidator<T>, rhs: ValueValidator<T?>) -> ValueValidator<T?> {
    return NilIgnoringValidator(lhs).validator() || rhs
}

internal func && <T>(lhs: ValueValidator<T?>, rhs: ValueValidator<T>) -> ValueValidator<T?> {
    return lhs && NilIgnoringValidator(rhs).validator()
}

internal func && <T>(lhs: ValueValidator<T>, rhs: ValueValidator<T?>) -> ValueValidator<T?> {
    return NilIgnoringValidator(lhs).validator() && rhs
}

private struct NilIgnoringValidator<T>: ValueValidatorType {

    let base: ValueValidator<T>

    init(_ base: ValueValidator<T>) {
        self.base = base
    }

    func validate(_ data: T?) throws {
        if let data = data {
            try base.validate(data)
        }
    }

    var validatorReadable: String {
        return base.readable
    }

}
