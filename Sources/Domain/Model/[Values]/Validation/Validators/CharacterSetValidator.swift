import Foundation

extension ValueValidator {

    static var alphanumeric: ValueValidator<String> {
        return .characterSet(.alphanumerics)
    }

    static func characterSet(_ characterSet: CharacterSet) -> ValueValidator<String> {
        return CharacterSetValidator(characterSet).validator()
    }

}

extension CharacterSet {

    static func + (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        return lhs.union(rhs)
    }

}

private struct CharacterSetValidator: ValueValidatorType {
    let characterSet: CharacterSet

    init(_ characterSet: CharacterSet) {
        self.characterSet = characterSet
    }

    func validate(_ string: String) throws {
        if let range = string.rangeOfCharacter(from: characterSet.inverted) {
            throw ValueValidationError("contains an invalid character: '\(string[range])'")
        }
    }

    var validatorReadable: String {
        return "in character set"
    }

}
