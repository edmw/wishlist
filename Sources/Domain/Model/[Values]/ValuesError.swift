import Foundation

// MARK: AnyValuesError

public protocol AnyValuesError: Error {}

// MARK: ValuesError

public enum ValuesError<V: Values>: AnyValuesError, CustomStringConvertible {

    case uniquenessViolated(for: PartialKeyPath<V>)
    case validationFailed(on: [PartialKeyPath<V>], reason: String)

    // MARK: CustomStringConvertible

    public var description: String {
        switch self {
        case .uniquenessViolated:
            return "ValuesError.uniquenessViolated"
        case let .validationFailed(_, reason):
            return "ValuesError.validationFailed with reason: \"\(reason)\""
        }
    }

}
