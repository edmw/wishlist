import Foundation

public protocol ListModel {
    var id: UUID? { get }
    var title: Title { get }
    var visibility: Visibility { get }
    var createdAt: Date { get }
    var modifiedAt: Date { get }
    var options: List.Options { get }
    var itemsSorting: ItemsSorting? { get }
    var userID: UUID { get }
}
