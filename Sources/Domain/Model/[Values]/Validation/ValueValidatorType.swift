import Foundation

protocol ValueValidatorType {

    associatedtype ValueValidationData

    func validate(_ data: ValueValidationData) throws

    var validatorReadable: String { get }

}

extension ValueValidatorType {

    func validator() -> ValueValidator<ValueValidationData> {
        return ValueValidator(validatorReadable, validate)
    }

}
