import Vapor

/// Defines some common functions to be of use in protected resources controllers.
///
/// An resource needing identification is only accessible to a client with a subject identifier.
extension ProtectedController {

    /// Returns the identification from the session. Creates a session if there is none.
    /// If there is no identification attached to an existing session, a new identification
    /// will be created and attached.
    /// It is possible to overwrite a generated identification by providing the id as query
    /// parameter to the request.
    @available(*, deprecated)
    static func requireIdentification(on request: Request) throws -> Identification {
        return try request.requireIdentification()
    }
    func requireIdentification(on request: Request) throws -> Identification {
        return try request.requireIdentification()
    }

}
