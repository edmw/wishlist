import Foundation
import NIO

// MARK: InvitationValues

/// Representation of an invitation without any internal properties and with simple types.
/// Used for validation, importing and exporting.
public struct InvitationValues: Values, ValueValidatable {
    typealias EntityType = Invitation

    public var code: InvitationCode?
    public var status: Invitation.Status?
    public var email: EmailSpecification
    public var sentAt: Date?
    public var createdAt: Date?

    internal init(
        code: InvitationCode?,
        status: Invitation.Status?,
        email: EmailSpecification,
        sentAt: Date?,
        createdAt: Date?
    ) {
        self.code = code
        self.status = status
        self.email = email
        self.sentAt = sentAt
        self.createdAt = createdAt
    }

    public init(
        code codeString: String?,
        status statusString: String?,
        email: String,
        sentAt: Date?,
        createdAt: Date?
    ) {
        if let codeString = codeString {
            self.code = InvitationCode(string: codeString)
        }
        self.status = Invitation.Status(string: statusString)
        self.email = EmailSpecification(string: email)
        self.sentAt = sentAt
        self.createdAt = createdAt
    }

    // MARK: Validatable

    static func valueValidations() throws -> ValueValidations<InvitationValues> {
        var validations = ValueValidations(InvitationValues.self)
        validations.add(\.email, "email", .emailSpecification)
        return validations
    }

    /// Validates the given invitation data on conformance to the constraints of the model.
    /// - Values must validate (see Validatable)
    func validate(
        for user: User,
        using repository: InvitationRepository
    ) throws -> EventLoopFuture<InvitationValues> {
        do {
            try validateValues()
        }
        catch let error as ValueValidationErrors<InvitationValues> {
            return repository.future(
                error: ValuesError<InvitationValues>
                    .validationFailed(on: error.failedKeyPaths, reason: error.reason)
            )
        }
        // validate for new invitation:
        // no constraints
        return repository.future(self)
    }

}

// MARK: -

extension Invitation {

    convenience init(for user: User, from data: InvitationValues) throws {
        try self.init(
            code: data.code,
            status: data.status,
            email: data.email,
            sentAt: data.sentAt,
            user: user
        )
    }

}
