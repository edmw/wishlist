import Foundation

protocol ValueValidationErrorType: Error, CustomStringConvertible {

    var keys: [String] { get set }

    var reason: String { get }

}

extension ValueValidationErrorType {

    // MARK: CustomStringConvertible

    var description: String {
        return "Value validation failed on '\(keys.joined(separator: "."))' with '\(reason)'"
    }

}
