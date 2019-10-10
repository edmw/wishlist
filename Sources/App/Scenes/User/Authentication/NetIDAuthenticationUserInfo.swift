import Vapor

struct NetIDAuthenticationUserInfo: AuthenticationUserInfo, Content, Validatable, Reflectable {

    let subjectId: String
    let email: String
    let givenName: String
    let familyName: String

    var name: String {
        return [givenName, familyName].joined(separator: " ")
    }
    var picture: URL? {
        return nil
    }
    var language: String? {
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case subjectId = "sub"
        case email = "email"
        case givenName = "given_name"
        case familyName = "family_name"
    }

    // MARK: - Validatable

    static func validations() throws -> Validations<NetIDAuthenticationUserInfo> {
        var validations = Validations(NetIDAuthenticationUserInfo.self)
        try validations.add(\.subjectId, !.empty)
        return validations
    }

}
