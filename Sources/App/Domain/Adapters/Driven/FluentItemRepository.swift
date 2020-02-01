import Domain

import Vapor
import Fluent
import FluentSQL
import FluentMySQL

// MARK: FluentItemRepository

/// Adapter for port `ItemRepository` using MySQL database.
final class FluentItemRepository: ItemRepository, FluentRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Items** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    // default sort order
    static let orderByNameKeyPath = \Item.title
    static let orderByNameDirection = EntitySortingDirection.ascending
    static let orderByName = ItemsSorting(orderByNameKeyPath, orderByNameDirection)
    static let orderByNameSql = MySQLDatabase.querySort(
        MySQLDatabase.queryField(.keyPath(orderByNameKeyPath)),
        orderByNameDirection.sqlDirection
    )

    func find(by id: ItemID) -> EventLoopFuture<Item?> {
        return db.withConnection { connection in
            return FluentItem.find(id.uuid, on: connection)
                .mapToEntity()
        }
    }

    func find(by id: ItemID, in list: List) throws -> EventLoopFuture<Item?> {
        return db.withConnection { connection in
            return try list.model.items.query(on: connection)
                .filter(\.id == id.uuid)
                .first()
                .mapToEntity()
        }
    }

    func findWithReservation(by id: ItemID, in list: List)
        throws -> EventLoopFuture<(Item, Reservation?)?>
    {
        return db.withConnection { connection in
            return try list.model.items.query(on: connection)
                .filter(\.id == id.uuid)
                .join(\FluentReservation.itemID, to: \FluentItem.id, method: .left)
                .decodeRaw()
                .all()
                .flatMap { results -> EventLoopFuture<(Item, Reservation?)?> in
                    return self.decodeItemsWithReservations(results, on: connection)
                        .map { $0.first }
                }
        }
    }

    func findWithListAndUser(by itemid: ItemID, in listid: ListID, for userid: UserID)
        -> EventLoopFuture<(Item, List, User)?>
    {
        return db.withConnection { connection in
            return FluentUser.query(on: connection)
                .join(\FluentList.userID, to: \FluentUser.id)
                .join(\FluentItem.listID, to: \FluentList.id)
                .filter(\.id == userid.uuid)
                .filter(\FluentList.id == listid.uuid)
                .filter(\FluentItem.id == itemid.uuid)
                .alsoDecode(FluentList.self)
                .alsoDecode(FluentItem.self)
                .first()
                .mapToEntities()
        }
    }

    func all(for list: List) throws -> EventLoopFuture<[Item]> {
        return try all(for: list, sort: FluentItemRepository.orderByName)
    }

    func all(
        for list: List,
        sort: ItemsSorting
    ) throws -> EventLoopFuture<[Item]> {
        let orderBy = try? sort.sqlOrderBy(on: FluentItem.self)
            ?? sortingDefault.sqlOrderBy(on: FluentItem.self)
        return db.withConnection { connection in
            var query = try list.model.items.query(on: connection)
            if let orderBy = orderBy {
                query = query.sort(orderBy)
            }
            return query
                .sort(\.title, .ascending)
                .all()
                .mapToEntities()
        }
    }

    func all(for list: List, reserved: Bool) throws -> EventLoopFuture<[Item]> {
        return db.withConnection { connection -> EventLoopFuture<[Item]> in
            let filterReserved: FilterOperator<MySQLDatabase, FluentReservation>
                = .make(\FluentReservation.id, reserved ? .notEqual : .equal, [UUID?.none])
            return try list.model.items.query(on: connection)
                .join(\FluentReservation.id, to: \FluentItem.id)
                .filter(filterReserved)
                .sort(\.title, .ascending)
                .all()
                .mapToEntities()
        }
    }

    func allAndReservations(
        for list: List
    ) throws -> EventLoopFuture<[(Item, Reservation?)]> {
        return try allAndReservations(for: list, sort: FluentItemRepository.orderByName)
    }

    func allAndReservations(
        for list: List,
        sort: ItemsSorting
    ) throws -> EventLoopFuture<[(Item, Reservation?)]> {
        let orderBy = try? sort.sqlOrderBy(on: FluentItem.self)
            ?? sortingDefault.sqlOrderBy(on: FluentItem.self)
        return db.withConnection { connection in
// TASK: This query executes a left join.
//
// CAVEAT: This will crash:
// Only full joins are supported by fluent right now. This left join will produce results
// with no reservation linked to an item, which will crash in `alsoDecode`.
//
//            return try list.items.query(on: connection)
//                .join(\FluentReservation.id, to: \FluentItem.id, method: .left)
//                .alsoDecode(FluentReservation.self)
//                .all()
//
// WORKAROUND: Let's roll up our sleeves:
// Get raw data from query and decode the model ourself.
            var query = try list.model.items.query(on: connection)
                .join(\FluentReservation.itemID, to: \FluentItem.id, method: .left)
            if let orderBy = orderBy {
                query = query.sort(orderBy)
            }
            return query
                .sort(\.title, .ascending)
                .decodeRaw()
                .all()
                .flatMap { results -> EventLoopFuture<[(Item, Reservation?)]> in
                    return self.decodeItemsWithReservations(results, on: connection)
                }
// /TASK
        }
    }

    func all() -> EventLoopFuture<[Item]> {
        return db.withConnection { connection in
            return FluentItem.query(on: connection)
                .all()
                .mapToEntities()
        }
    }

    func count(on list: List) throws -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return try list.model.items.query(on: connection)
                .count()
        }
    }

    func save(item: Item) -> EventLoopFuture<Item> {
        return db.withConnection { connection in
            if item.id == nil {
                // item create
                let limit = Item.maximumNumberOfItemsPerList
                return FluentItem.query(on: connection)
                    .filter(\.listID == item.listID)
                    .count()
                    .max(limit, or: EntityError<Item>.limitReached(maximum: limit))
                    .transform(to:
                        item.model.save(on: connection)
                    )
                    .mapToEntity()
            }
            else {
                // item update
                return item.model.save(on: connection)
                    .mapToEntity()
            }
        }
    }

    private func delete(_ item: Item, in list: List, on connection: MySQLConnection)
        throws -> EventLoopFuture<Item?>
    {
        guard let listid = list.listID, listid == item.listID else {
            return connection.future(nil)
        }
        return item.model.delete(on: connection)
            .transform(to: item.detached())
    }

    func delete(item: Item, in list: List) throws -> EventLoopFuture<Item?> {
        return db.withConnection { connection in
            return try self.delete(item, in: list, on: connection)
        }
    }

    func delete(items: [Item], in list: List) throws -> EventLoopFuture<[Item]> {
        return db.withConnection { connection in
            var deletedItems: [EventLoopFuture<Item?>] = []
            for item in items {
                let deletedItem = try self.delete(item, in: list, on: connection)
                deletedItems.append(deletedItem)
            }
            return deletedItems.flatten(on: connection)
                .map { $0.compactMap { $0 } }
        }
    }

    private func decodeItemsWithReservations(
        _ results: [MySQLDatabase.Output],
        on connection: MySQLConnection
    ) -> EventLoopFuture<[(Item, Reservation?)]> {
        return db.withConnection { connection in
            return results.map { row -> EventLoopFuture<(Item, Reservation?)> in
                // decode item future
                let item = MySQLDatabase.queryDecodeItem(row, on: connection)
                // get reservation id if any or nil
                let reservationID = row.value(
                    forTable: FluentReservation.entity,
                    atColumn: FluentReservation.Database
                        .queryField(.keyPath(\FluentReservation.id)).identifier.string
                )
                if let id = reservationID, !id.isNull {
                    // decode reservation future
                    let reservation = MySQLDatabase.queryDecodeReservation(row, on: connection)
                    // return future of tuple from item and reservation
                    return flatMap(
                        to: (Item, Reservation?).self, item, reservation
                    ) { item, reservation in
                        connection.future((item, reservation))
                    }
                }
                else {
                    // return future of tuple from item and nil
                    return item.flatMap { item in
                        connection.future((item, nil))
                    }
                }
            }
            .flatten(on: connection) // flatten [F<()>] to F<[()]>
        }
    }

}

// MARK: -

extension MySQLDatabase {

    fileprivate static func queryDecodeItem(
        _ row: [MySQLColumn: MySQLData],
        on connection: MySQLConnection
    ) -> EventLoopFuture<Item> {
        return MySQLDatabase.queryDecode(
            row,
            entity: FluentItem.entity,
            as: FluentItem.self,
            on: connection
        )
        .mapToEntity()
    }

    fileprivate static func queryDecodeReservation(
        _ row: [MySQLColumn: MySQLData],
        on connection: MySQLConnection
    ) -> EventLoopFuture<Reservation> {
        return MySQLDatabase.queryDecode(
            row,
            entity: FluentReservation.entity,
            as: FluentReservation.self,
            on: connection
        )
        .mapToEntity()
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == ((FluentUser, FluentList), FluentItem)? {

    func mapToEntities() -> EventLoopFuture<(Item, List, User)?> {
        return self.map { models in
            guard let models = models else {
                return nil
            }
            return (Item(from: models.1), List(from: models.0.1), User(from: models.0.0))
        }
    }

}
