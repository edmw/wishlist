import Vapor
import Fluent
import FluentMySQL

// MARK: Entity

/// Item model
/// This type represents an item on a wishlist.
///
/// Relations:
/// - Parent: List
final class Item: Entity, EntityReflectable, Content, Imageable, CustomStringConvertible {

    // maximum number of items per list:
    // this is a hard limit (application can have soft limits, too)
    static let maximumNumberOfItemsPerList = 1_000

    static let minimumLengthOfName = 4
    static let maximumLengthOfName = 100

    static let maximumLengthOfText = 2_000

    static let maximumLengthOfURL = 2_000

    var id: UUID?

    var name: String
    var text: String
    var preference: Preference
    var url: URL?
    var imageURL: URL?
    var createdAt: Date
    var modifiedAt: Date

    var localImageURL: URL?

    /// Parent
    var listID: List.ID

    init(
        id: UUID? = nil,
        name: String,
        text: String,
        preference: Preference? = nil,
        url: URL? = nil,
        imageURL: URL? = nil,
        listID: List.ID
    ) throws {
        self.id = id

        self.name = name
        self.text = text
        self.preference = preference ?? .normal
        self.url = url
        self.imageURL = imageURL
        self.createdAt = Date()
        self.modifiedAt = self.createdAt

        self.listID = listID
    }

    convenience init(
        id: UUID? = nil,
        name: String,
        text: String,
        list: List
    ) throws {
        try self.init(id: id, name: name, text: text, listID: list.requireID())
    }

    // MARK: Imagable

    var imageableEntityGroupKey: String? {
        return listID.base62String
    }

    var imageableEntityKey: String? {
        return id?.base62String
    }

    var imageableSize: ImageableSize {
        return ImageableSize(width: 512, height: 512)
    }

    // MARK: EntityReflectable

    static var properties: [PartialKeyPath<Item>] = [
        \Item.id,
        \Item.name,
        \Item.text,
        \Item.preference,
        \Item.url,
        \Item.imageURL,
        \Item.localImageURL,
        \Item.createdAt,
        \Item.modifiedAt,
        \Item.listID
    ]

    static func propertyName(forKey keyPath: PartialKeyPath<Item>) -> String? {
        switch keyPath {
        case \Item.id: return "id"
        case \Item.name: return "name"
        case \Item.text: return "text"
        case \Item.preference: return "preference"
        case \Item.url: return "url"
        case \Item.imageURL: return "imageURL"
        case \Item.localImageURL: return "localImageURL"
        case \Item.createdAt: return "createdAt"
        case \Item.modifiedAt: return "modifiedAt"
        case \Item.listID: return "listID"
        default: return nil
        }
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "Item[\(id ??? "???")](\(name))"
    }

    // MARK: -

    enum Preference: Int, Codable, CustomStringConvertible {

        case lowest = -2
        case low = -1
        case normal = 0
        case high = 1
        case highest = 2

        init?(string value: String) {
            switch value {
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

        var description: String {
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
