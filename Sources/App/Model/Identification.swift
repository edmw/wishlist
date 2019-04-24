import Foundation

/// Identification entity:
/// This type is used to identify anonymous as well as authenticated users.
///
/// Instead of a simple type alias it would be much better to create a value type
/// here (see InvitationCode). But I'm lazy.
typealias Identification = UUID
