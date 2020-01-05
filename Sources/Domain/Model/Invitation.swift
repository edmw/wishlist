import Library

import Foundation

// MARK: Entity

/// Invitation model
/// This type represents an invitation for joining the site.
///
/// Relations:
/// - Parent: User
public final class Invitation: Entity, Confidental,
    EntityDetachable,
    EntityReflectable,
    Codable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    // maximum number of invitations per user:
    // this is a hard limit (application can have soft limits, too)
    public static let maximumNumberOfInvitationsPerUser = 10

    public var id: UUID?
    public var invitationID: InvitationID? { InvitationID(uuid: id) }

    public var code: InvitationCode
    public var status: Invitation.Status
    public var email: EmailSpecification
    public var sentAt: Date?
    public var createdAt: Date

    /// User (who initiated that invitation)
    public var userID: UUID

    /// User (who was invited)
    public var invitee: UUID?

    init(
        id: UUID? = nil,
        code: InvitationCode? = nil,
        status: Invitation.Status? = nil,
        email: EmailSpecification,
        sentAt: Date? = nil,
        user: User
    ) throws {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }

        self.id = id

        self.code = code ?? InvitationCode()
        self.status = status ?? Status.open
        self.email = email
        self.sentAt = sentAt
        self.createdAt = Date()

        self.userID = userid
    }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<Invitation> = .build(
        .init(\Invitation.id, label: "id"),
        .init(\Invitation.code, label: "code"),
        .init(\Invitation.status, label: "status"),
        .init(\Invitation.email, label: "email"),
        .init(\Invitation.sentAt, label: "sentAt"),
        .init(\Invitation.createdAt, label: "createdAt"),
        .init(\Invitation.userID, label: "userID"),
        .init(\Invitation.invitee, label: "invitee")
    )

    // MARK: CustomStringConvertible

    public var description: String {
        return "Invitation[\(id ??? "???")]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "Invitation[\(id ??? "???")]"
    }

    // MARK: - Status

    /// Status of an invitation. Can be one of `open`, `accepted`, `declined`, `revoked`.
    public enum Status: Int, Codable, CustomStringConvertible, LosslessStringConvertible {

        case open = 0
        case accepted = 1
        case declined = 2
        case revoked = 3

        public init?(string value: String) {
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

        public var description: String {
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

        // MARK: LosslessStringConvertible

        public init?(_ string: String) {
            self.init(string: string)
        }

    }

}
