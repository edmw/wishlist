import Vapor

struct GoogleAuthenticationUserInfo: AuthenticationUserInfo, Content, Validatable, Reflectable {

    static var provider = "google"

    let subjectId: String
    let email: String
    let name: String
    let givenName: String
    let familyName: String
    let picture: URL?
    let locale: String

    var language: String? {
        return locale
    }

    enum CodingKeys: String, CodingKey {
        case subjectId = "id"
        case email = "email"
        case name = "name"
        case givenName = "given_name"
        case familyName = "family_name"
        case picture = "picture"
        case locale = "locale"
    }

    // MARK: - Validatable

    static func validations() throws -> Validations<GoogleAuthenticationUserInfo> {
        var validations = Validations(GoogleAuthenticationUserInfo.self)
        try validations.add(\.subjectId, !.empty)
        return validations
    }

}
