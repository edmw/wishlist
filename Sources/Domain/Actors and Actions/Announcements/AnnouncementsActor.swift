import Foundation
import NIO

// MARK: AnnouncementsActor

/// Announcements use cases.
public protocol AnnouncementsActor: Actor {

    /// Presents publicly available information.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    ///
    /// Does mostly nothing, but returns an `UserRepresentation` if a user id is specified. This
    /// can be used to present different information for users.
    ///
    /// Specification:
    /// - `userID`: ID of the user to create the invitation for.
    ///
    /// Boundaries:
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result {
    ///     let user: UserRepresentation
    /// }
    /// ```
    func presentPublicly(
        _ specification: PresentPublicly.Specification,
        _ boundaries: PresentPublicly.Boundaries
    ) throws -> EventLoopFuture<PresentPublicly.Result>

}

/// This is the domain’s implementation of the Announcements use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainAnnouncementsActor: AnnouncementsActor {

    let userRepository: UserRepository

    public required init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

}
