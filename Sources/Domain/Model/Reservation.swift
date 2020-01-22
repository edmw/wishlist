import Foundation

import Library

// MARK: Entity

/// Reservation model
/// This type represents a reservation of an item by a user.
///
/// Relations:
/// - Foreign: Item
public final class Reservation: Entity,
    EntityDetachable,
    EntityReflectable,
    Loggable,
    Codable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    public var id: UUID? {
        didSet { reservationID = ReservationID(uuid: id) }
    }
    public lazy var reservationID = ReservationID(uuid: id)

    public var createdAt: Date

    /// Item (what item is reserved)
    public var itemID: UUID

    /// Holder (who reserved that item)
    public var holder: Identification

    init(
        id: ReservationID? = nil,
        item: Item,
        holder: Identification
    ) throws {
        guard let itemid = item.id else {
            throw EntityError<Item>.requiredIDMissing
        }

        self.id = id?.uuid

        self.createdAt = Date()

        self.itemID = itemid

        self.holder = holder
    }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<Reservation> = .build(
        .init(\Reservation.id, label: "id"),
        .init(\Reservation.createdAt, label: "createdAt"),
        .init(\Reservation.itemID, label: "itemID"),
        .init(\Reservation.holder, label: "holder")
    )

    // MARK: CustomStringConvertible

    public var description: String {
        return "Reservation[\(id ??? "???"):\(reservationID ??? "???")]" +
            "(item:\(itemID)|holder:\(holder))"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "Reservation[\(id ??? "???"):\(reservationID ??? "???")]" +
            "(item:\(itemID))|holder:\(holder))"
    }

}
