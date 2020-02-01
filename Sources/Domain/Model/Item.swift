import Foundation

import Library

// MARK: Entity

/// Item model
/// This type represents an item on a wishlist.
///
/// Relations:
/// - Parent: List
public final class Item: ItemModel, Imageable,
    Entity,
    EntityDetachable,
    EntityReflectable,
    Loggable,
    Codable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    // maximum number of items per list:
    // this is a hard limit (application can have soft limits, too)
    public static let maximumNumberOfItemsPerList = 1_000

    public static let minimumLengthOfTitle = 4
    public static let maximumLengthOfTitle = 100

    public static let maximumLengthOfText = 2_000

    public static let maximumLengthOfURL = 2_000

    public var id: UUID? {
        didSet { itemID = ItemID(uuid: id) }
    }
    public lazy var itemID = ItemID(uuid: id)

    public var title: Title
    public var text: Text
    public var preference: Item.Preference
    public var url: URL?
    public var imageURL: URL?
    public var createdAt: Date
    public var modifiedAt: Date

    public var localImageURL: URL?

    /// Parent
    public var listID: UUID

    public init<T: ItemModel>(from other: T) {
        self.id = other.id
        self.title = other.title
        self.text = other.text
        self.preference = other.preference
        self.url = other.url
        self.imageURL = other.imageURL
        self.createdAt = other.createdAt
        self.modifiedAt = other.modifiedAt
        self.localImageURL = other.localImageURL
        self.listID = other.listID
    }

    init(
        id: UUID? = nil,
        title: Title,
        text: Text,
        preference: Item.Preference? = nil,
        url: URL? = nil,
        imageURL: URL? = nil,
        list: List
    ) throws {
        guard let listid = list.id else {
            throw EntityError<List>.requiredIDMissing
        }

        self.id = id

        self.title = title
        self.text = text
        self.preference = preference ?? .normal
        self.url = url
        self.imageURL = imageURL
        self.createdAt = Date()
        self.modifiedAt = self.createdAt

        self.listID = listid
    }

    var values: ItemValues { .init(self) }

    // MARK: Imagable

    public var imageableEntityGroupKey: String? {
        return listID.base62String
    }

    public var imageableEntityKey: String? {
        return id?.base62String
    }

    public var imageableSize: ImageableSize {
        return ImageableSize(width: 512, height: 512)
    }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<Item> = .build(
        .init(\Item.id, label: "id"),
        .init(\Item.title, label: "title"),
        .init(\Item.text, label: "text"),
        .init(\Item.preference, label: "preference"),
        .init(\Item.url, label: "url"),
        .init(\Item.imageURL, label: "imageURL"),
        .init(\Item.localImageURL, label: "localImageURL"),
        .init(\Item.createdAt, label: "createdAt"),
        .init(\Item.modifiedAt, label: "modifiedAt"),
        .init(\Item.listID, label: "listID")
    )

    // MARK: CustomStringConvertible

    public var description: String {
        return "Item[\(id ??? "???")]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "Item[\(id ??? "???")](\(title))"
    }

    // MARK: - Preference

    public enum Preference: Int, Codable, LosslessStringConvertible, CustomStringConvertible {

        case lowest = -2
        case low = -1
        case normal = 0
        case high = 1
        case highest = 2

        public init?(_ description: String) {
            switch description {
            case "lowest":  self = .lowest
            case "low":     self = .low
            case "normal":  self = .normal
            case "high":    self = .high
            case "highest": self = .highest
            default:
                return nil
            }
        }

        // MARK: CustomStringConvertible

        public var description: String {
            switch self {
            case .lowest:
                return "lowest"
            case .low:
                return "low"
            case .normal:
                return "normal"
            case .high:
                return "high"
            case .highest:
                return "highest"
            }
        }

    }

}
