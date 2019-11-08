import Vapor

import Foundation

protocol AnyEntity: AnyObject {
}

protocol Entity: AnyEntity {

    var id: UUID? { get }

}

extension Entity where Self: EntityReflectable {

    static var propertyNameForId: String {
        return "id"
    }

}
