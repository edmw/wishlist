import Domain

import Vapor

protocol AuthenticationUserInfo {

    static var provider: String { get }

    var subjectId: String { get }

    var email: String { get }
    var name: String { get }
    var givenName: String { get }
    var familyName: String { get }
    var picture: URL? { get }
    var language: String? { get }

    func validate() throws

}

extension UserIdentity {

    /// Creates a user identity from the given authentication user info.
    init(from userInfo: AuthenticationUserInfo) {
        self.init(string: userInfo.subjectId)
    }

}

extension UserIdentityProvider {

    /// Creates a user identity provider from the given authentication user info.
    init(from userInfo: AuthenticationUserInfo) {
        self.init(string: type(of: userInfo).provider)
    }

}

extension PartialValues where Wrapped == UserValues {

    /// Creates user values from the given authentication user info.
    init(from userInfo: AuthenticationUserInfo) {
        self.init()
        self[\.email] = EmailSpecification(userInfo.email)
        self[\.fullName] = userInfo.name
        self[\.firstName] = userInfo.givenName
        self[\.lastName] = userInfo.familyName
        self[\.language] = userInfo.language
        self[\.picture] = userInfo.picture
    }

}
