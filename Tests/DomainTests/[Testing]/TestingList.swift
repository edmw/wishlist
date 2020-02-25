@testable import Domain
import Testing

extension List {

    static func randomList(for user: User) -> List {
        return try! List(for: user, from: randomListValues())
    }

    static func randomListValues() -> ListValues {
        var values = PartialValues<ListValues>()
        values[\.title] = Lorem.randomTitle()
        values[\.visibility] = .´public´
        values[\.options] = []
        return try! ListValues(values)
    }

    func withFakeID() -> Self {
        self.id = .init()
        return self
    }

}
