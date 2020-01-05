import Foundation

internal prefix func ! <T>(rhs: ValueValidator<T>) -> ValueValidator<T> {
    return NotValidator(rhs).validator()
}

private struct NotValidator<T>: ValueValidatorType {
    typealias ValidationData = T

    let rhs: ValueValidator<T>

    init(_ rhs: ValueValidator<T>) {
        self.rhs = rhs
    }

    func validate(_ data: T) throws {
        var right: ValueValidationErrorType?
        do {
            try rhs.validate(data)
        }
        catch let error as ValueValidationErrorType {
            right = error
        }
        guard right != nil else {
            throw ValueValidationError("is \(rhs)")
        }
    }

    var validatorReadable: String {
        return "not \(rhs.readable)"
    }

}
