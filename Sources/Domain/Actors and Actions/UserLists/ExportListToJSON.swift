import Foundation
import NIO

// MARK: ExportListToJSON

public struct ExportListToJSON: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let name: String
        public let json: String
        internal init(_ user: User, name: String, json: String) {
            self.user = user.representation
            self.name = name
            self.json = json
        }
    }

    // MARK: -

    internal let actor: () -> ExportListToJSONActor

    internal init(actor: @escaping @autoclosure () -> ExportListToJSONActor) {
        self.actor = actor
    }

    private func exportName(for list: List) -> String {
        let listtitle = list.title.slugify()
        let datestamp = Date().exportDatestamp()
        var components = ["wishlist"]
        if let listtitle = listtitle {
            components.append(listtitle)
        }
        components.append(datestamp)
        return components.joined(separator: "-")
    }

    // MARK: Execute

    internal func execute(with list: List, for user: User, in boundaries: Boundaries) throws
        -> EventLoopFuture<(name: String, json: String?)>
    {
        let actor = self.actor()
        let itemRepository = actor.itemRepository
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let name = exportName(for: list)
        return try itemRepository
            .all(for: list)
            .map { items in
                let values = ListValues(list, items)
                let data = try encoder.encode(values)
                let json = String(data: data, encoding: .utf8)
                return (name, json)
            }
    }

}

// MARK: -

protocol ExportListToJSONActor {
    var listRepository: ListRepository { get }
    var itemRepository: ItemRepository { get }
    var logging: MessageLoggingProvider { get }
}

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: exportList

    public func exportList(
         _ specification: ExportListToJSON.Specification,
         _ boundaries: ExportListToJSON.Boundaries
    ) throws -> EventLoopFuture<ExportListToJSON.Result> {
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                return try self.listRepository
                    .find(by: specification.listID, for: user)
                    .unwrap(or: UserListsActorError.invalidList)
                    .flatMap { list in
                        return try ExportListToJSON(actor: self)
                            .execute(with: list, for: user, in: boundaries)
                            .recordEvent(for: list, "exported for \(user)", using: self.recording)
                            .logMessage(
                                .exportList(list, user), for: { $0.0 }, using: self.logging
                            )
                            .map { name, json in
                                guard let json = json else {
                                    throw UserListsActorError
                                        .exportErrorForUser(user.representation)
                                }
                                return .init(user, name: name, json: json)
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    static func exportList(_ list: List, _ user: User) -> Self {
        return Self({ subject in
            LoggingMessage(label: "Export List", subject: subject, attributes: [list, user])
        })
    }

}

// MARK: Date

extension Date {

    fileprivate func exportDatestamp() -> String {
        return DateFormatter.ExportDatestampFormatter.string(from: self)
    }

}

// MARK: DateFormatter

extension DateFormatter {

    fileprivate static let ExportDatestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

}
