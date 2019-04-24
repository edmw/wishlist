import Vapor
import Fluent
import FluentMySQL

// MARK: Entity

/// Reservation model
/// This type represents a reservation of an item by a user.
///
/// Relations:
/// - Foreign: Item
final class Reservation: Entity, EntityReflectable, Content, CustomStringConvertible {

    var id: UUID?

    var createdAt: Date

    /// Item (what item is reserved)
    var itemID: Item.ID

    /// Holder (who reserved that item)
    var holder: Identification

    init(
        id: UUID? = nil,
        itemID: Item.ID,
        holder: Identification
    ) throws {
        self.id = id

        self.createdAt = Date()

        self.itemID = itemID

        self.holder = holder
    }

    convenience init(
        id: UUID? = nil,
        item: Item,
        holder: Identification
    ) throws {
        try self.init(id: id, itemID: item.requireID(), holder: holder)
    }

    // MARK: EntityReflectable

    static var properties: [PartialKeyPath<Reservation>] = [
        \Reservation.id,
        \Reservation.createdAt,
        \Reservation.itemID,
        \Reservation.holder
    ]

    static func propertyName(forKey keyPath: PartialKeyPath<Reservation>) -> String? {
        switch keyPath {
        case \Reservation.id: return "id"
        case \Reservation.createdAt: return "createdAt"
        case \Reservation.itemID: return "itemID"
        case \Reservation.holder: return "holder"
        default: return nil
        }
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "Reservation[\(id ??? "???")](\(itemID))"
    }

}
