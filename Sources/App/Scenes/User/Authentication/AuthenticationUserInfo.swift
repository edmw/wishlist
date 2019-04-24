import Vapor

protocol AuthenticationUserInfo {

    var subjectId: String { get }

    var email: String { get }
    var name: String { get }
    var givenName: String { get }
    var familyName: String { get }
    var picture: URL { get }
    var language: String? { get }

    func validate() throws

}

extension User {

    convenience init(_ userInfo: AuthenticationUserInfo) {
        self.init(
            id: nil,
            email: userInfo.email,
            name: userInfo.name,
            firstName: userInfo.givenName,
            lastName: userInfo.familyName
        )
        self.subjectId = userInfo.subjectId
        self.language = userInfo.language
        self.picture = userInfo.picture
    }

    func update(_ userInfo: AuthenticationUserInfo) {
        self.email = userInfo.email
        self.name = userInfo.name
        self.firstName = userInfo.givenName
        self.lastName = userInfo.familyName
        self.language = userInfo.language
        self.picture = userInfo.picture
    }

}
