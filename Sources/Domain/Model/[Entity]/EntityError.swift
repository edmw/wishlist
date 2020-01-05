import Foundation

// MARK: AnyEntityError

public protocol AnyEntityError: Error {}

// MARK: EntityError

public enum EntityError<T: Entity & EntityReflectable>: AnyEntityError,
    Equatable,
    CustomStringConvertible
{
    // Properties
    case requiredIDMissing
    case requiredIDMismatch
    // Entities
    case lookupFailed(for: AnyIdentifier)
    case limitReached(maximum: Int)

    public var description: String {
        switch self {
        case .requiredIDMissing:
            return "\(T.self): required ID missing"
        case .requiredIDMismatch:
            return "\(T.self): required ID mismatch"
        case let(.lookupFailed(id)):
            return "\(T.self): entity missing with id \(id)"
        case let(.limitReached(maximum)):
            return "\(T.self): limit of \(maximum) entities reached"
        }
    }

    // MARK: Equatable

    public static func == (lhs: EntityError<T>, rhs: EntityError<T>) -> Bool {
        switch (lhs, rhs) {
        case (.requiredIDMissing, .requiredIDMissing):
            return true
        case (.requiredIDMismatch, .requiredIDMismatch):
            return true
        case let (.lookupFailed(lhsid), .lookupFailed(rhsid)):
            return lhsid.uuid == rhsid.uuid
        case let (.limitReached(lhsMaximum), .limitReached(rhsMaximum)):
            return lhsMaximum == rhsMaximum
        case (.requiredIDMissing, _),
             (.requiredIDMismatch, _),
             (.lookupFailed, _),
             (.limitReached, _):
            return false
        }
    }

}
