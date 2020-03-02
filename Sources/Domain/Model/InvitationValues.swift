import Foundation
import NIO

// MARK: InvitationValues

/// Representation of an invitation with external properties and basic types, only.
/// Used for validation, importing and exporting.
public struct InvitationValues: Values, ValueValidatable {

    public var code: String?
    public var status: String?
    public var email: String
    public var sentAt: Date?
    public var createdAt: Date?

    /// Creates invitation values from individual invitation values.
    init(
        code: InvitationCode?,
        status: Invitation.Status?,
        email: EmailSpecification,
        sentAt: Date?,
        createdAt: Date?
    ) {
        self.code = code.flatMap(String.init)
        self.status = status.flatMap(String.init)
        self.email = String(email)
        self.sentAt = sentAt
        self.createdAt = createdAt
    }

    /// Creates list values from simple data types. For example from user input.
    public init(
        code: String?,
        status: String?,
        email: String,
        sentAt: Date?,
        createdAt: Date?
    ) {
        self.code = code
        self.status = status
        self.email = email
        self.sentAt = sentAt
        self.createdAt = createdAt
    }

    // MARK: Validatable

    static func valueValidations() throws -> ValueValidations<InvitationValues> {
        var validations = ValueValidations(InvitationValues.self)
        validations.add(\.email, "email", .email)
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
            code: data.code.flatMap(InvitationCode.init),
            status: data.status.flatMap(Invitation.Status.init),
            email: EmailSpecification(data.email),
            sentAt: data.sentAt,
            user: user
        )
    }

}
