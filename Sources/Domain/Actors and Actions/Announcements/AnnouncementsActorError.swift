/// Errors thrown by the Announcements actor.
enum AnnouncementsActorError: Error {
    /// An invalid user id was specified. There is no user with the given id.
    case invalidUser
}
