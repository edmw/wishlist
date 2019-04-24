import Vapor

extension Request {

    /// Returns the identification from the session. Creates a session if there is none.
    /// If there is no identification attached to an existing session, a new identification
    /// will be created and attached.
    /// It is possible to overwrite a generated identification be providing the id as query
    /// parameter to the request.
    func requireIdentification() throws -> Identification {
        if let idString = query[.id],
            let id = Identification(base62String: idString) {
            // identification from request parameter has highest precedence
            // (overwrites identification in session)
            try session()["identification"] = id.base62String
            return id
        }
        else {
            if let idString = try session()["identification"],
                let id = Identification(base62String: idString) {
                // identification from session
                return id
            }
            else {
                // create new identification
                // (stores identification in session)
                let id = Identification()
                let idString = id.base62String
                try session()["identification"] = idString
                return id
            }
        }
    }

    /// Sets the identification for the session. Overwrites an existing identification.
    func setIdentification(_ id: Identification?) throws {
        try session()["identification"] = id?.base62String
    }

    /// Clears the identification for the session.
    func clearIdentification() throws {
        try session()["identification"] = nil
    }

}
