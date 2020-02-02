import Foundation

public protocol ItemModel {
    var id: ItemID? { get }
    var title: Title { get }
    var text: Text { get }
    var preference: Item.Preference { get }
    var url: URL? { get }
    var imageURL: URL? { get }
    var createdAt: Date { get }
    var modifiedAt: Date { get }
    var localImageURL: URL? { get }
    var listID: ListID { get }
}
