@testable import Domain
import Testing

extension User {

    static func randomUser() -> User {
        return try! User(from: randomUserValues())
    }

    static func randomUserValues() -> UserValues {
        let firstName = Lorem.randomFirstName()
        let lastName = Lorem.randomLastName()
        var values = PartialValues<UserValues>()
        values[\.email] = "\(lastName)@email.invalid"
        values[\.fullName] = "\(firstName) \(lastName)"
        values[\.firstName] = firstName
        values[\.lastName] = lastName
        return try! UserValues(values)
    }

    func withFakeID() -> Self {
        self.id = .init()
        return self
    }

}
