import Vapor
import Fluent
import FluentMySQL

import Foundation

extension ModelQuerySorting: MySQLModelQuerySorting {}

protocol MySQLModelQuerySorting {

    /// Maps this to a corresponding `MySQLOrderBy`
    func orderBy<M: Model>(on model: M.Type) throws -> MySQLOrderBy?
        where M.Database == MySQLDatabase

}

extension MySQLModelQuerySorting where Self: ModelQuerySorting {

    /// Maps this to a corresponding `MySQLOrderBy`:
    /// Constructs the sql orderby structure for the specified model and the stored property name
    /// and order direction. Checks if the specified model type does have a property with the
    /// stored name. Returns `nil` otherwise.
    func orderBy<M: Model & Reflectable >(on model: M.Type) throws -> MySQLOrderBy?
        where M.Database == MySQLDatabase
    {
        guard !propertyName.isEmpty else {
            return nil
        }

        let properties = try M.reflectProperties(depth: 0).compactMap { $0.path.first }
        guard properties.contains(propertyName) else {
            return nil
        }

        let modelName = "\(model)"
        let tableIdentifier = MySQLTableIdentifier(MySQLIdentifier(modelName))
        let columnIdentifier = MySQLIdentifier(propertyName)
        let queryDirection = direction.sqlDirection
        return M.Database.querySort(.column(tableIdentifier, columnIdentifier), queryDirection)
    }

}
