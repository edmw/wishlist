/// Errors thrown by the User Invitations actor.
public enum UserInvitationsActorError: Error {
    case invalidUser
    case invalidInvitation
    case invalidInvitationStatus(Invitation.Status)
    case validationError(
        UserRepresentation,
        InvitationRepresentation?,
        ValuesError<InvitationValues>
    )
}
