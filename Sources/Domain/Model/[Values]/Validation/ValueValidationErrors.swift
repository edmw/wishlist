import Foundation

struct ValueValidationErrors<V>: Error {

    private var errors: [PartialKeyPath<V>: [ValueValidationErrorType]]

    var failedKeyPaths: [PartialKeyPath<V>] {
        return Array(errors.keys)
    }

    var reason: String {
        return errors.values.joined().map { $0.description }.joined(separator: ", ")
    }

    init(_ errors: [PartialKeyPath<V>: [ValueValidationErrorType]]) {
        precondition(!errors.isEmpty)
        self.errors = errors
    }

}
