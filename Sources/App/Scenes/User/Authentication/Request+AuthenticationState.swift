import Vapor

import Foundation

extension Request {

    /// Creates an authentication state and stores the associated token in the session.
    func createState() throws -> String? {
        // create an authentication state
        var authenticationState = try AuthenticationState()
        authenticationState.locator = query.getLocator()
        authenticationState.invitationCode = query[.invitationCode]
        // encode authentication state to string
        let encoder = try make(ContentCoders.self).requireDataEncoder(for: .json)
        let stateData = try encoder.encode(authenticationState)
        let stateString = String(data: stateData, encoding: .utf8)
        // put associated authentication token into session
        try session().set(authenticationToken: authenticationState.token)

        return stateString
    }

    /// Verifies the specified authentication state string with the state stored in the session.
    /// Does not throw any error but logs errors into technical debug log and returns false instead.
    func verifyState(_ stateString: String) -> Bool {
        let decoder: DataDecoder
        do {
            decoder = try make(ContentCoders.self).requireDataDecoder(for: .json)
        }
        catch {
            logger?.technical.debug("AuthenticationState: \(error)")
            return false
        }

        // decode authentication state from string
        let authenticationState: AuthenticationState

        guard let stateData = stateString.data(using: .utf8) else {
            logger?.technical.debug("AuthenticationState: Invalid string to decode into data")
            return false
        }
        do {
            authenticationState = try decoder.decode(AuthenticationState.self, from: stateData)
        }
        catch {
            logger?.technical.debug("AuthenticationState: Invalid string to decode with \(error)")
            return false
        }

        return verifyState(authenticationState)
    }

    /// Verifies the specified authentication state with the state stored in the session.
    /// Does not throw any error but logs errors into technical debug log and returns false instead.
    func verifyState(_ authenticationState: AuthenticationState) -> Bool {
        // get authentication token from session
        guard let authenticationToken = try? session().getAuthenticationToken() else {
            logger?.technical.debug("AuthenticationState: Missing authentication token in session")
            return false
        }
        // verify associated authentication token with token from session
        guard authenticationState.token == authenticationToken else {
            logger?.technical.debug("AuthenticationState: Invalid authentication token in session")
            return false
        }
        return true
    }

    /// Returns the authentication state given in the request’s query.
    func getAuthenticationStateFromQuery() throws -> AuthenticationState? {
        // get state string from request query
        let stateString = try query.get(String.self, at: "state")
        guard let stateData = stateString.data(using: .utf8) else {
            return nil
        }
        // decode authentication state from string
        let decoder = try make(ContentCoders.self).requireDataDecoder(for: .json)
        let authenticationState = try decoder.decode(AuthenticationState.self, from: stateData)

        return authenticationState
    }

}
