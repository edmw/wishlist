import Foundation

public protocol InvitationModel {
    var id: InvitationID? { get }
    var code: InvitationCode { get }
    var status: Invitation.Status { get }
    var email: EmailSpecification { get }
    var sentAt: Date? { get }
    var createdAt: Date { get }
    var userID: UserID { get }
    var inviteeID: UserID? { get }
}
