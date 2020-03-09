// sourcery:inline:FluentReservation.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentReservation

/// This generated type is based on the Domain‘s Reservation model type and is used for
/// storing data into and retrieving data from a SQL database using Fluent.
///
/// The Domain builds relations between models using model identifiers (UserID, ListID, ...).
/// This will translate model identifiers to UUIDs and vice versa to handle relations using UUIDs.
public struct FluentReservation: ReservationModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.uuid
    public static let name = "Reservation"
    public static let migrationName = "Reservation"

    public var uuid: UUID?
    public var id: ReservationID? { ReservationID(uuid: uuid) }
    public var status: Reservation.Status
    public var createdAt: Date
    public var itemKey: UUID
    public var itemID: ItemID { ItemID(uuid: itemKey) }
    public var holder: Identification

    /// Initializes a SQL layer's `FluentReservation`. Usually not called directly.
    /// To create this object a getter `model` is provided on the Domain entity `Reservation`.
    init(
        uuid: UUID?,
        status: Reservation.Status,
        createdAt: Date,
        itemKey: UUID,
        holder: Identification
    ) {
        self.uuid = uuid
        self.status = status
        self.createdAt = createdAt
        self.itemKey = itemKey
        self.holder = holder
    }

    enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case status
        case createdAt
        case itemKey = "itemID"
        case holder
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.uuid)
            builder.field(for: \.status)
            builder.field(for: \.createdAt)
            builder.field(for: \.itemKey)
            builder.field(for: \.holder)
            builder.reference(from: \.itemKey, to: \FluentItem.uuid, onDelete: .cascade)
        }
    }

    // MARK: Relations

    var item: Parent<FluentReservation, FluentItem> {
        return parent(\FluentReservation.itemKey)
    }

    func requireItem(on container: Container) throws -> EventLoopFuture<Item> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.item.get(on: connection).mapToEntity()
        }
    }

    // MARK: Equatable

    public static func == (lhs: FluentReservation, rhs: FluentReservation) -> Bool {
        guard lhs.uuid == rhs.uuid else {
            return false
        }
        guard lhs.status == rhs.status else {
            return false
        }
        guard lhs.createdAt == rhs.createdAt else {
            return false
        }
        guard lhs.itemKey == rhs.itemKey else {
            return false
        }
        guard lhs.holder == rhs.holder else {
            return false
        }
        return true
    }

}

// MARK: - Reservation

extension Reservation {

    var model: FluentReservation {
        return .init(
            uuid: id?.uuid,
            status: status,
            createdAt: createdAt,
            itemKey: itemID.uuid,
            holder: holder
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentReservation {

    /// Maps this future‘s expectation from an SQL layer's `FluentReservation`
    /// to the Domain entity `Reservation`.
    func mapToEntity() -> EventLoopFuture<Reservation> {
        return self.map { model in
            return Reservation(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentReservation? {

    /// Maps this future‘s expectation from an SQL layer's optional `FluentReservation`
    /// to the optional Domain entity `Reservation`.
    func mapToEntity() -> EventLoopFuture<Reservation?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return Reservation(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentReservation] {

    /// Maps this future‘s expectation from an array of SQL layer's `FluentReservation`s
    /// to an array of the Domain entities `Reservation`s.
    func mapToEntities() -> EventLoopFuture<[Reservation]> {
        return self.map { models in
            return models.map { model in Reservation(from: model) }
        }
    }

}
// sourcery:end
