import Foundation

internal func && <T>(lhs: ValueValidator<T>, rhs: ValueValidator<T>) -> ValueValidator<T> {
    return AndValidator(lhs, rhs).validator()
}

private struct AndValidator<T>: ValueValidatorType {

    let lhs: ValueValidator<T>
    let rhs: ValueValidator<T>

    init(_ lhs: ValueValidator<T>, _ rhs: ValueValidator<T>) {
        self.lhs = lhs
        self.rhs = rhs
    }

    func validate(_ data: T) throws {
        var left: ValueValidationErrorType?
        do {
            try lhs.validate(data)
        }
        catch let error as ValueValidationErrorType {
            left = error
        }

        var right: ValueValidationErrorType?
        do {
            try rhs.validate(data)
        }
        catch let error as ValueValidationErrorType {
            right = error
        }

        if left != nil || right != nil {
            throw AndValidatorError(left, right)
        }
    }

    var validatorReadable: String {
        return "\(lhs.readable) and is \(rhs.readable)"
    }

}

struct AndValidatorError: ValueValidationErrorType {

    var keys: [String] = []

    let left: ValueValidationErrorType?
    let right: ValueValidationErrorType?

    var reason: String {
        if let left = left, let right = right {
            return "\(left.reason) and \(right.reason)"
        }
        else if let left = left {
            return left.reason
        }
        else if let right = right {
            return right.reason
        }
        else {
            return ""
        }
    }

    init(_ left: ValueValidationErrorType?, _ right: ValueValidationErrorType?) {
        self.left = left
        self.right = right
    }

}
