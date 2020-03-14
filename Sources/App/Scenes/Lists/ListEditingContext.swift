import Domain

// MARK: ListEditingContext

struct ListEditingContext: Codable {

    var data: ListEditingData?

    var invalidTitle: Bool = false
    var invalidVisibility: Bool = false
    var duplicateName: Bool = false

    static var empty: ListEditingContext { return .init(with: nil) }

    init(with data: ListEditingData?) {
        self.data = data
    }

    init(from list: ListRepresentation?) {
        if let list = list {
            self.init(with: ListEditingData(from: list))
        }
        else {
            self.init(with: ListEditingData())
        }
    }

}
