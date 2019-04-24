import Vapor
import Fluent

import Foundation

enum ModelError<M: Model>: Error, CustomStringConvertible {

    // IDs
    case requiredIDMissing
    case requiredIDMismatch

    var description: String {
        switch self {
        case .requiredIDMissing:
            return "\(M.self): required ID missing"
        case .requiredIDMismatch:
            return "\(M.self): required ID mismatch"
        }
    }

}
