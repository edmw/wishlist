import Foundation

extension String {

    public func replacingCharacters(everyNth: Int, with replacement: Character) -> String {
        precondition(everyNth > 1)

        return String(
            enumerated().map { index, char in index % everyNth != 0 ? char : replacement }
        )
    }

}
