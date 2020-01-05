import Foundation

/// This type represents an identifier used to identify anonymous as well as authenticated users.
/// Any reservation for an item will be attached to this identifier. This allows anonymous as well
/// as authenticated users to make reservations. In a rather complex process this application tries
/// to merge anonymously made reservations for user which authenticate at a later point in time.
public struct Identification: Identifier {

    /// Let me introduce to you: The identification itself.
    public let rawValue: UUID

    /// Creates an identification using the specified UUID.
    public init(uuid: UUID) {
        self.rawValue = uuid
    }

}
