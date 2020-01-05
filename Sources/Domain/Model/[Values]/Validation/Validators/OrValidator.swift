import Foundation

internal func || <T>(lhs: ValueValidator<T>, rhs: ValueValidator<T>) -> ValueValidator<T> {
    return OrValidator(lhs, rhs).validator()
}

private struct OrValidator<T>: ValueValidatorType {

    let lhs: ValueValidator<T>
    let rhs: ValueValidator<T>

    init(_ lhs: ValueValidator<T>, _ rhs: ValueValidator<T>) {
        self.lhs = lhs
        self.rhs = rhs
    }

    func validate(_ data: T) throws {
        do {
            try lhs.validate(data)
        }
        catch let left as ValueValidationErrorType {
            do {
                try rhs.validate(data)
            }
            catch let right as ValueValidationErrorType {
                throw OrValidatorError(left, right)
            }
        }
        catch {
            print(error)
        }
    }

    var validatorReadable: String {
        return "\(lhs.readable) or is \(rhs.readable)"
    }

}

private struct OrValidatorError: ValueValidationErrorType {

    var keys: [String] = []

    let left: ValueValidationErrorType
    let right: ValueValidationErrorType

    var reason: String {
        return "\(left.reason) and \(right.reason)"
    }

    init(_ left: ValueValidationErrorType, _ right: ValueValidationErrorType) {
        self.left = left
        self.right = right
    }

}
