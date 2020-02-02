import Foundation

public protocol UserModel {
    var id: UserID? { get }
    var identification: Identification { get }
    var email: EmailSpecification { get }
    var fullName: String { get }
    var firstName: String { get }
    var lastName: String { get }
    var nickName: String? { get }
    var language: LanguageTag? { get }
    var picture: URL? { get }
    var confidant: Bool { get }
    var settings: UserSettings { get }
    var firstLogin: Date? { get }
    var lastLogin: Date? { get }
    var identity: UserIdentity? { get }
    var identityProvider: UserIdentityProvider? { get }
}
