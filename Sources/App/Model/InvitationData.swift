import Vapor

/// Representation of an invitation without any internal properties
/// and with simple types.
/// Used for validation, importing and exporting.
struct InvitationData: Content, Validatable, Reflectable {

    var code: InvitationCode?
    var status: Invitation.Status?
    var email: String
    var sentAt: Date?
    var createdAt: Date?

    // MARK: Validatable

    static func validations() throws -> Validations<InvitationData> {
        var validations = Validations(InvitationData.self)
        try validations.add(\.email, (.email && .count(0...Invitation.maximumLengthOfEmail)))
        return validations
    }

    /// Validates the given invitation data on conformance to the constraints of the model.
    /// - Values must validate (see Validatable)
    func validate(
        for user: User,
        using repository: InvitationRepository
    ) throws -> Future<InvitationData> {
        do {
            try validate()
        }
        catch let error as ValidationError {
            var properties = [PartialKeyPath<Invitation>]()
            // WORKAROUND: See https://github.com/vapor/validation/issues/26
            // This is a hack which parses the textual reason for an validation error.
            let reason = error.reason
            if reason.contains("'email'") {
                properties.append(\Invitation.email)
            }
            throw EntityError.validationFailed(on: properties, reason: reason)
        }
        // validate for new invitation:
        // no constraints
        return repository.future(self)
    }

}

// MARK: -

extension Invitation {

    convenience init(for user: User, from data: InvitationData) throws {
        try self.init(
            code: data.code,
            status: data.status,
            email: data.email,
            sentAt: data.sentAt,
            user: user
        )
    }

}
