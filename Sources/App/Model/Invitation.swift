import Vapor

// MARK: Entity

/// Invitation model
/// This type represents an invitation for joining the site.
///
/// Relations:
/// - Parent: User
final class Invitation: Entity, EntityReflectable, Content, CustomStringConvertible {

    // maximum number of invitations per user:
    // this is a hard limit (application can have soft limits, too)
    static let maximumNumberOfInvitationsPerUser = 10

    static let maximumLengthOfEmail = 250

    var id: UUID?

    var code: InvitationCode
    var status: Status
    var email: String
    var sentAt: Date?
    var createdAt: Date

    /// User (who initiated that invitation)
    var userID: User.ID

    /// User (who was invited)
    var invitee: User.ID?

    init(
        id: UUID? = nil,
        code: InvitationCode? = nil,
        status: Status? = nil,
        email: String,
        sentAt: Date? = nil,
        user: User
    ) throws {
        self.id = id

        self.code = try code ?? InvitationCode()
        self.status = status ?? Status.open
        self.email = email
        self.sentAt = sentAt
        self.createdAt = Date()

        self.userID = try user.requireID()
    }

    func update(status value: Invitation.Status, in repository: InvitationRepository) throws
        -> Future<Invitation>
    {
        switch value {
        case .accepted:
            if status == .open || status == .accepted {
                status = value
            }
            else {
                throw InvitationError.invalidStatus
            }
        case .revoked:
            if status == .open || status == .revoked {
                status = value
            }
            else {
                throw InvitationError.invalidStatus
            }
        default:
            throw InvitationError.invalidStatus
        }
        return repository.save(invitation: self)
    }

    // MARK: EntityReflectable

    static var properties: [PartialKeyPath<Invitation>] = [
        \Invitation.id,
        \Invitation.code,
        \Invitation.status,
        \Invitation.email,
        \Invitation.sentAt,
        \Invitation.createdAt,
        \Invitation.userID,
        \Invitation.invitee
    ]

    static func propertyName(forKey keyPath: PartialKeyPath<Invitation>) -> String? {
        switch keyPath {
        case \Invitation.id: return "id"
        case \Invitation.code: return "code"
        case \Invitation.status: return "status"
        case \Invitation.email: return "email"
        case \Invitation.sentAt: return "sentAt"
        case \Invitation.createdAt: return "createdAt"
        case \Invitation.userID: return "userID"
        case \Invitation.invitee: return "invitee"
        default: return nil
        }
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "Invitation[\(id ??? "???")](\(email))"
    }

    // MARK: -

    enum Status: Int, Codable, CustomStringConvertible {

        case open = 0
        case accepted = 1
        case declined = 2
        case revoked = 3

        init?(string value: String) {
            switch value {
            case "open":     self = .open
            case "accepted": self = .accepted
            case "declined": self = .declined
            case "revoked":  self = .revoked
            default:
                return nil
            }
        }

        // MARK: CustomStringConvertible

        var description: String {
            switch self {
            case .open:
                return "open"
            case .accepted:
                return "accepted"
            case .declined:
                return "declined"
            case .revoked:
                return "revoked"
            }
        }

    }

}
