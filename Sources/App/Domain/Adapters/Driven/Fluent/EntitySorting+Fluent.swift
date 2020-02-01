import Domain

import Vapor
import Fluent
import FluentMySQL

import Foundation

extension EntitySorting {

    /// Maps this to a corresponding `MySQLOrderBy`:
    /// Constructs the sql orderby structure for the specified model and the stored property name
    /// and order direction. Checks if the specified model type does have a property with the
    /// stored name. Returns `nil` otherwise.
    func sqlOrderBy<M: Fluent.Model & Reflectable>(on model: M.Type) throws -> MySQLOrderBy?
        where M.Database == MySQLDatabase
    {
        let modelName = model.name

        guard !propertyName.isEmpty else {
            return nil
        }

        let properties = try M.reflectProperties(depth: 0).compactMap { $0.path.first }
        guard properties.contains(propertyName) else {
            return nil
        }

        let tableIdentifier = MySQLTableIdentifier(MySQLIdentifier(modelName))
        let columnIdentifier = MySQLIdentifier(propertyName)
        let queryDirection = direction.sqlDirection
        return M.Database.querySort(.column(tableIdentifier, columnIdentifier), queryDirection)
    }

}

extension EntitySortingDirection {

    var sqlDirection: GenericSQLDirection {
        switch self {
        case .ascending:
            return .ascending
        case .descending:
            return .descending
        }
    }

}
