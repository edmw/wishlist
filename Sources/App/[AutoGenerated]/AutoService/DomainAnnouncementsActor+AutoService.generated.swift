// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Vapor

// MARK: DomainAnnouncementsActor

/// Adapter for the domain layers `DomainAnnouncementsActor` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension DomainAnnouncementsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [AnnouncementsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            userRepository: container.make()
        )
    }

}
