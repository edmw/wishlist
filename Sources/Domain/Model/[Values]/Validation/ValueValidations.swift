import Foundation

struct ValueValidations<V>: CustomStringConvertible where V: ValueValidatable {

    fileprivate var validators: [PartialKeyPath<V>: ValueValidator<V>]

    init(_ value: V.Type) {
        self.validators = [:]
    }

    mutating func add<T>(
        _ keypath: KeyPath<V, T>,
        _ key: String,
        _ validator: ValueValidator<T>
    ) {
        add(keypath, key, "is " + validator.readable, validate: { value in
            try validator.validate(value)
        })
    }

    mutating func add<T>(
        _ keypath: KeyPath<V, T>,
        _ key: String,
        _ readable: String,
        validate: @escaping (T) throws -> Void
    ) {
        let validator: ValueValidator<V> = .init(readable) { value in
            do {
                try validate(value[keyPath: keypath])
            }
            catch var error as ValueValidationErrorType {
                error.keys += [key]
                throw error
            }
        }
        validators[keypath] = validator
    }

    mutating func add(
        _ readable: String,
        validate: @escaping (V) throws -> Void
    ) {
        let validator: ValueValidator<V> = .init(readable) { value in
            do {
                try validate(value)
            }
            catch var error as ValueValidationErrorType {
                error.keys += ["self"]
                throw error
            }
        }
        validators[\V.self] = validator
    }

    func run(on value: V) throws {
        var errors: [PartialKeyPath<V>: [ValueValidationErrorType]] = [:]
        for (keypath, validator) in validators {
            do {
                try validator.validate(value)
            }
            catch let error as ValueValidationErrorType {
                errors[keypath] = errors[keypath, default: []] + [error]
            }
        }
        if !errors.isEmpty {
            throw ValueValidationErrors(errors)
        }
    }

    // MARK: CustomStringConvertible

    public var description: String {
        validators.values.map { $0.description }.joined(separator: "\n")
    }

}
