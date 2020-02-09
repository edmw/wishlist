import Foundation

extension ValueValidator where T == PushoverKey {

    static var pushoverKey: ValueValidator<T> {
        return PushoverKeyValidator().validator()
    }

}

struct PushoverKeyValidator: ValueValidatorType {

    init() {}

    func validate(_ key: PushoverKey) throws {
        let string = String(key)
        guard
            let range = string.range(
                of: "[A-Z0-9a-z]{30}",
                options: [.regularExpression]
            ),
            range.lowerBound == string.startIndex && range.upperBound == string.endIndex
        else {
            throw ValueValidationError("is not a valid pushover key (pattern)")
        }
    }

    var validatorReadable: String {
        return "a valid pushover key"
    }

}
