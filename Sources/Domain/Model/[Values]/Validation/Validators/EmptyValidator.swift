extension ValueValidator where T: Collection {

    static var empty: ValueValidator<T> {
        return EmptyValidator().validator()
    }

}

struct EmptyValidator<T>: ValueValidatorType where T: Collection {

    func validate(_ data: T) throws {
        guard data.isEmpty else {
            throw ValueValidationError("is not empty")
        }
    }

    var validatorReadable: String {
        return "empty"
    }

}
