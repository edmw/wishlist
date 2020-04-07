/// Errors thrown by the Enrollment actor.
enum EnrollmentActorError: Error {
    case userCreationNotAllowed
    case invitationForUserCreationNotProvided
}
