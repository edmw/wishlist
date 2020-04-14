import Foundation

import Library

// MARK: Reservation

/// Reservation model
/// This type represents a reservation of an item by a user.
///
/// Relations:
/// - Foreign: Item
public final class Reservation: ReservationModel, Representable,
    DomainEntity,
    DomainEntityDetachable,
    DomainEntityReflectable,
    Loggable,
    Codable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    // MARK: Entity

    public internal(set) var id: ReservationID?

    public internal(set) var status: Reservation.Status
    public internal(set) var createdAt: Date

    /// Item (what item is reserved)
    public internal(set) var itemID: ItemID

    /// Holder (who reserved that item)
    public internal(set) var holder: Identification

    public init<T: ReservationModel>(from other: T) {
        self.id = other.id
        self.status = other.status
        self.createdAt = other.createdAt
        self.itemID = other.itemID
        self.holder = other.holder
    }

    init(
        id: ReservationID? = nil,
        item: Item,
        holder: Identification
    ) throws {
        guard let itemid = item.id else {
            throw EntityError<Item>.requiredIDMissing
        }

        self.id = id

        self.status = .open
        self.createdAt = Date()

        self.itemID = itemid

        self.holder = holder
    }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<Reservation> = .build(
        .init(\Reservation.id, label: "id"),
        .init(\Reservation.status, label: "status"),
        .init(\Reservation.createdAt, label: "createdAt"),
        .init(\Reservation.itemID, label: "itemID"),
        .init(\Reservation.holder, label: "holder")
    )

    // MARK: CustomStringConvertible

    public var description: String {
        return "Reservation[\(optional: id)][item:\(itemID)|holder:\(holder)]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "Reservation[\(optional: id)][item:\(itemID))|holder:\(holder)]"
    }

    // MARK: - Status

    /// Status of an reservation. Can be one of `open`, `closed`.
    public enum Status: Int, Codable, CustomStringConvertible, LosslessStringConvertible {

        /// A open reservation can be deleted. Items with an open reservation attached can not be
        /// moved or archived.
        case open = 0
        /// A closed reservation can not be deleted. A reservation can not be reopened. Items with
        /// a closed reservation attached can be moved or archived.
        case closed = 1

        public init?(string value: String?) {
            guard let value = value else {
                return nil
            }
            switch value {
            case "open":     self = .open
            case "closed":   self = .closed
            default:
                return nil
            }
        }

        // MARK: CustomStringConvertible

        public var description: String {
            switch self {
            case .open:
                return "open"
            case .closed:
                return "closed"
            }
        }

        // MARK: LosslessStringConvertible

        public init?(_ string: String) {
            self.init(string: string)
        }

    }

}
