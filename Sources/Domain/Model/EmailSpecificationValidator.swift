import Foundation

extension ValueValidator where T == EmailSpecification {

    static var emailSpecification: ValueValidator<T> {
        return EmailSpecificationValidator().validator()
    }

}

struct EmailSpecificationValidator: ValueValidatorType {

    init() {}

    func validate(_ specification: EmailSpecification) throws {
        let string = String(specification)
        guard string.count < 250 else {
            throw ValueValidationError("is not a valid email specification (length)")
        }
        guard
            let range = string.range(
                of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
                options: [.regularExpression, .caseInsensitive]
            ),
            range.lowerBound == string.startIndex && range.upperBound == string.endIndex
        else {
            throw ValueValidationError("is not a valid email specification (pattern)")
        }
    }

    var validatorReadable: String {
        return "a valid email specification"
    }

}
