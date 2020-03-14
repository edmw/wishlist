import Domain

// MARK: ItemEditingContext

struct ItemEditingContext: Codable {

    var data: ItemEditingData?

    var invalidTitle: Bool = false
    var invalidText: Bool = false
    var invalidURL: Bool = false
    var invalidImageURL: Bool = false

    static var empty: ItemEditingContext { return .init(with: nil) }

    init(with data: ItemEditingData?) {
        self.data = data
    }

    init(from item: ItemRepresentation?) {
        if let item = item {
            self.init(with: ItemEditingData(from: item))
        }
        else {
            self.init(with: ItemEditingData())
        }
    }

}
