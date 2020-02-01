import Foundation

public protocol InvitationModel {
    var id: UUID? { get }
    var code: InvitationCode { get }
    var status: Invitation.Status { get }
    var email: EmailSpecification { get }
    var sentAt: Date? { get }
    var createdAt: Date { get }
    var userID: UUID { get }
    var invitee: UUID? { get }
}
