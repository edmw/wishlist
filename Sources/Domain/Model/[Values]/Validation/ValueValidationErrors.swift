import Foundation

struct ValueValidationErrors<V>: Error, CustomStringConvertible {

    private var errors: [PartialKeyPath<V>: [ValueValidationErrorType]]

    var failedKeyPaths: [PartialKeyPath<V>] {
        return Array(errors.keys)
    }

    var reason: String {
        return errors.values
            .joined()
            .map { String(reflecting: $0) }
            .sorted()
            .joined(separator: ", ")
    }

    init(_ errors: [PartialKeyPath<V>: [ValueValidationErrorType]]) {
        precondition(!errors.isEmpty)
        self.errors = errors
    }

    // MARK: CustomStringConvertible

    var description: String {
        return reason
    }

}
