// sourcery:inline:FluentReservation.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentReservation

/// This generated type is based on the Domain‘s FluentReservation model type and is used for
/// storing data to and retrieving data from a SQL database using Fluent.
public struct FluentReservation: ReservationModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id
    public static let name = "Reservation"
    public static let migrationName = "Reservation"

    public var id: UUID?
    public var createdAt: Date
    public var itemID: UUID
    public var holder: Identification

    init(
        id: UUID?,
        createdAt: Date,
        itemID: UUID,
        holder: Identification
    ) {
        self.id = id
        self.createdAt = createdAt
        self.itemID = itemID
        self.holder = holder
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.createdAt)
            builder.field(for: \.itemID)
            builder.field(for: \.holder)
            builder.reference(from: \.itemID, to: \FluentItem.id, onDelete: .cascade)
        }
    }

    // MARK: Relations

    var item: Parent<FluentReservation, FluentItem> {
        return parent(\FluentReservation.itemID)
    }

    func requireItem(on container: Container) throws -> EventLoopFuture<Item> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.item.get(on: connection).mapToEntity()
        }
    }

    // MARK: Equatable

    public static func == (lhs: FluentReservation, rhs: FluentReservation) -> Bool {
        guard lhs.id == rhs.id else {
            return false
        }
        guard lhs.createdAt == rhs.createdAt else {
            return false
        }
        guard lhs.itemID == rhs.itemID else {
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
            id: id,
            createdAt: createdAt,
            itemID: itemID,
            holder: holder
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentReservation? {

    func mapToEntity() -> EventLoopFuture<Reservation?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return Reservation(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentReservation {

    func mapToEntity() -> EventLoopFuture<Reservation> {
        return self.map { model in
            return Reservation(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentReservation] {

    func mapToEntities() -> EventLoopFuture<[Reservation]> {
        return self.map { models in
            return models.map { model in Reservation(from: model) }
        }
    }

}
// sourcery:end
