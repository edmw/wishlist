import Foundation

extension String {

    public var hasLetters: Bool {
        return rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
    }

    public var isLetters: Bool {
        return CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: self))
    }

    public var hasDigits: Bool {
        return rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
    }

    public var isDigits: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }

}
