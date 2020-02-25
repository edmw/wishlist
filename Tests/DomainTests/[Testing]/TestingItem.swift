@testable import Domain
import Testing

extension Item {

    static func randomItem(for list: List) -> Item {
        return try! Item(for: list, from: randomItemValues())
    }

    static func randomItemValues() -> ItemValues {
        var values = PartialValues<ItemValues>()
        values[\.title] = Lorem.randomTitle()
        values[\.text] = Lorem.randomParagraph()
        values[\.preference] = .normal
        values[\.url] = Lorem.randomURL().absoluteString
        values[\.imageURL] = Lorem.randomURL().absoluteString
        return try! ItemValues(values)
    }

    func withFakeID() -> Self {
        self.id = .init()
        return self
    }

}
