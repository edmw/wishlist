import Foundation

extension ValueValidator where T == String {

    static var email: ValueValidator<T> {
        return EmailValidator().validator()
    }

}

private struct EmailValidator: ValueValidatorType {
    typealias ValueValidationData = String

    public init() {}

    func validate(_ data: String) throws {
        guard data.count < 250 else {
            throw ValueValidationError("is not a valid email (length)")
        }
        guard
            let range = data.range(
                of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
                options: [.regularExpression, .caseInsensitive]
            ),
            range.lowerBound == data.startIndex && range.upperBound == data.endIndex
        else {
            throw ValueValidationError("is not a valid email (pattern)")
        }
    }

    var validatorReadable: String {
        return "a valid email"
    }

}
