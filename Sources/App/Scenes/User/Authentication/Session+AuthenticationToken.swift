import Vapor

extension Session {

    func set(authenticationToken: AuthenticationToken) throws {
        self["_authentication_token"] = authenticationToken.stringValue
    }

    func getAuthenticationToken() throws -> AuthenticationToken? {
        guard let tokenString = self["_authentication_token"] else {
            return nil
        }
        return AuthenticationToken(string: tokenString)
    }

}
