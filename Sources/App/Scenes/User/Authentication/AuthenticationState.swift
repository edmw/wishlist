import Domain

import Vapor
import Random

extension ControllerParameterKeys {
    static let authenticationState = ControllerParameterKey<AuthenticationState>("state")
}

struct AuthenticationState: ControllerParameterValue,
    Codable
{

    let token: AuthenticationToken

    var locator: Locator?

    var invitationCode: InvitationCode?

    init() throws {
        self.token = try AuthenticationToken()
    }

    // MARK: - ControllerParameterValue

    var stringValue: String {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            fatalError("AuthenticationState: Encoding to JSON data failed!")
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            fatalError("AuthenticationState: Encoding to JSON string failed!")
        }
        return jsonString
    }

    init?(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        guard let state = try? JSONDecoder().decode(AuthenticationState.self, from: jsonData) else {
            return nil
        }
        self = state
    }

}
