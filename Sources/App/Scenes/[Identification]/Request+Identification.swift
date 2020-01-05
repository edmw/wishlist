import Domain

import Vapor

extension Request {

    /// Returns the identification from the session.
    ///
    /// If there is no identification attached to an existing session, a new identification
    /// will be created and attached. Creates a session if there is none. It is possible to
    /// overwrite a generated identification by providing the id as query parameter to the
    /// request.
    func requireIdentification() throws -> Identification {
        if let idString = query[.id],
            let id = Identification(idString) {
            // identification from request parameter has highest precedence
            // (overwrites identification in session)
            try session()["identification"] = String(id)
            return id
        }
        else {
            if let idString = try session()["identification"],
                let id = Identification(idString) {
                // identification from session
                return id
            }
            else {
                // create new identification
                // (stores identification in session)
                let id = Identification()
                try session()["identification"] = String(id)
                return id
            }
        }
    }

    /// Sets the identification for the session. Overwrites an existing identification.
    func setIdentificationForSession(_ id: Identification?) throws {
        if let id = id {
            try session()["identification"] = String(id)
        }
        else {
            try session()["identification"] = nil
        }
    }

    /// Clears the identification from the session.
    func clearSessionFromIdentification() throws {
        try session()["identification"] = nil
    }

}
