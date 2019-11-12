import Vapor
import Fluent
import FluentSQL
import FluentMySQL

/// Adapter for port `ItemRepository` using MySQL database.
final class MySQLItemRepository: ItemRepository, MySQLModelRepository {

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

    func find(by id: Item.ID) -> EventLoopFuture<Item?> {
        return db.withConnection { connection in
            return Item.find(id, on: connection)
        }
    }

    func find(by id: Item.ID, in list: List) throws -> EventLoopFuture<Item?> {
        return db.withConnection { connection in
            return try list.items.query(on: connection).filter(\.id == id).first()
        }
    }

    func findWithReservation(by id: Item.ID, in list: List)
        throws -> EventLoopFuture<(Item, Reservation?)?>
    {
        return db.withConnection { connection in
            return try list.items
                .query(on: connection)
                .filter(\.id == id)
                .join(\Reservation.itemID, to: \Item.id, method: .left)
                .decodeRaw()
                .all()
                .flatMap { results -> EventLoopFuture<(Item, Reservation?)?> in
                    return self.decodeItemsWithReservations(
                        results,
                        on: connection
                    )
                    .map { $0.first }
                }
        }
    }

    func all(for list: List) throws -> EventLoopFuture<[Item]> {
        return try all(for: list, sort: MySQLItemRepository.orderByName)
    }

    func all(
        for list: List,
        sort: ItemsSorting
    ) throws -> EventLoopFuture<[Item]> {
        return db.withConnection { connection in
            let orderBy = (try? sort.sqlOrderBy(on: Item.self))
                                ???? MySQLItemRepository.orderByNameSql
            return try list.items
                .query(on: connection)
                .sort(orderBy)
                .sort(\.title, .ascending)
                .all()
        }
    }

    func all(for list: List, reserved: Bool) throws -> EventLoopFuture<[Item]> {
        return db.withConnection { connection -> EventLoopFuture<[Item]> in
            let filterReserved: FilterOperator<MySQLDatabase, Reservation>
                = .make(\Reservation.id, reserved ? .notEqual : .equal, [UUID?.none])
            return try list.items
                .query(on: connection)
                .join(\Reservation.id, to: \Item.id)
                .filter(filterReserved)
                .sort(\.title, .ascending)
                .all()
        }
    }

    func allAndReservations(
        for list: List
    ) throws -> EventLoopFuture<[(Item, Reservation?)]> {
        return try allAndReservations(for: list, sort: MySQLItemRepository.orderByName)
    }

    func allAndReservations(
        for list: List,
        sort: ItemsSorting
    ) throws -> EventLoopFuture<[(Item, Reservation?)]> {
        let orderBy = (try? sort.sqlOrderBy(on: Item.self))
                            ???? MySQLItemRepository.orderByNameSql
        return db.withConnection { connection in
// TASK: This query executes a left join.
//
// CAVEAT: This will crash:
// Only full joins are supported by fluent right now. This left join will produce results
// with no reservation linked to an item, which will crash in `alsoDecode`.
//
//            return try list.items
//                .query(on: connection)
//                .join(\Reservation.id, to: \Item.id, method: .left)
//                .alsoDecode(Reservation.self)
//                .all()
//
// WORKAROUND: Let's roll up our sleeves:
// Get raw data from query and decode the model ourself.
            return try list.items
                .query(on: connection)
                .join(\Reservation.itemID, to: \Item.id, method: .left)
                .sort(orderBy)
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
            return Item.query(on: connection).all()
        }
    }

    func count(on list: List) throws -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return try list.items.query(on: connection).count()
        }
    }

    func save(item: Item) -> EventLoopFuture<Item> {
        return db.withConnection { connection in
            if item.id == nil {
                // item create
                let limit = Item.maximumNumberOfItemsPerList
                return Item.query(on: connection)
                    .filter(\.listID == item.listID)
                    .count()
                    .max(limit, or: EntityError<Item>.limitReached(maximum: limit))
                    .transform(to:
                        item.save(on: connection)
                    )
            }
            else {
                // item update
                return item.save(on: connection)
            }
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
                    forTable: Reservation.entity,
                    atColumn: Reservation.Database
                        .queryField(.keyPath(\Reservation.id)).identifier.string
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

    // MARK: - Service

    static let serviceSupports: [Any.Type] = [ItemRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
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
            entity: Item.entity,
            as: Item.self,
            on: connection
        )
    }

    fileprivate static func queryDecodeReservation(
        _ row: [MySQLColumn: MySQLData],
        on connection: MySQLConnection
    ) -> EventLoopFuture<Reservation> {
        return MySQLDatabase.queryDecode(
            row,
            entity: Reservation.entity,
            as: Reservation.self,
            on: connection
        )
    }

}
