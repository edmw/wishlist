import Vapor

import Foundation

enum EntityError<T: Entity & EntityReflectable>: Error, CustomStringConvertible {

    // Properties
    case requiredIDMissing
    case requiredIDMismatch
    case uniquenessViolated(for: PartialKeyPath<T>)
    case validationFailed(on: [PartialKeyPath<T>], reason: String)
    // Entities
    case lookupFailed(for: UUID)
    case limitReached(maximum: Int)

    var description: String {
        switch self {
        case .requiredIDMissing:
            return "\(T.self): required ID missing"
        case .requiredIDMismatch:
            return "\(T.self): required ID mismatch"
        case let(.validationFailed(properties, reason)):
            let names = properties.map { property in T.propertyName(forKey: property) }
            let strings = names.map { name in "'\(name ??? "�")'" }
            let string = strings.joined(separator: ", ")
            return "\(T.self): validation failed on properties: \(string) [\(reason)]"
        case let(.uniquenessViolated(property)):
            let name = T.propertyName(forKey: property)
            let string = "'\(name ??? "�")'"
            return "\(T.self): uniqueness violated on property: \(string)"
        case let(.lookupFailed(id)):
            return "\(T.self): entity missing with id \(id)"
        case let(.limitReached(maximum)):
            return "\(T.self): limit of \(maximum) entities reached"
        }
    }

}
