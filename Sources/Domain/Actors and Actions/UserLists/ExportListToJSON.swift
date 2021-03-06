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
        public let name: FileName
        public let json: String
        internal init(_ user: User, name: FileName, json: String) {
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

    private func exportName(for list: List) -> FileName {
        let listtitle = String(list.title).slugify()
        let datestamp = Date().exportDatestamp()
        var components = ["wishlist"]
        if let listtitle = listtitle {
            components.append(listtitle)
        }
        components.append(datestamp)
        return FileName(components.joined(separator: "-"))
    }

    // MARK: Execute

    internal func execute(with list: List, for user: User, in boundaries: Boundaries) throws
        -> EventLoopFuture<(name: FileName, json: String?)>
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
    var logging: MessageLogging { get }
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
                            .logMessage(
                                .exportList(list, user), for: { $0.0 }, using: self.logging
                            )
                            .recordEvent(
                                .exportList(list, user), for: { $0.0 }, using: self.recording
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

    fileprivate static func exportList(_ list: List, _ user: User)
        -> LoggingMessageRoot<FileName>
    {
        return .init({ name in
            LoggingMessage(label: "Export List", subject: name, loggables: [list, user])
        })
    }

}

// MARK: Recording

extension RecordingEventRoot {

    fileprivate static func exportList(_ list: List, _ user: User)
        -> RecordingEventRoot<FileName>
    {
        return .init({ name in
            RecordingEvent(.EXPORTDATA, subject: name, attributes: ["list": list, "user": user])
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
