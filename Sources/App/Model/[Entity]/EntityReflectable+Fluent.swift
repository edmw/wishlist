import Vapor
import Fluent

extension EntityReflectable where Self: Model {

    static var propertyNameForIdKey: String? {
        return propertyName(forKey: idKey)
    }

}
