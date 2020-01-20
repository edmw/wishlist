import Foundation
import NIO

// MARK: RequestItemMovement

public struct RequestItemMovement: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public let itemID: ItemID
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        public let item: ItemRepresentation
        public let lists: [ListRepresentation]
        internal init(_ user: User, _ list: List, _ item: Item, lists: [ListRepresentation]) {
            self.user = user.representation
            self.list = list.representation
            self.item = item.representation
            self.lists = lists
        }
    }

}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: RequestItemMovement

    public func requestItemMovement(
        _ specification: RequestItemMovement.Specification,
        _ boundaries: RequestItemMovement.Boundaries
    ) throws -> EventLoopFuture<RequestItemMovement.Result> {
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        let worker = boundaries.worker
        return try self.itemRepository
            .findWithListAndUser(by: itemid, in: listid, for: userid)
            .unwrap(or: UserItemsActorError.invalidItem)
            .flatMap { item, list, user in
                return try self.listRepresentationsBuilder
                    .reset()
                    .forUser(user)
                    .build(on: worker)
                    .map { lists in .init(user, list, item, lists: lists) }
            }
    }



//        return try self.requireList(on: request, for: user).flatMap { list in
//    return try self.requireItem(on: request, for: list).flatMap { item in
//        let listRepresentationsBuilder
//            = ListRepresentationsBuilder(self.listRepository, self.itemRepository)
//                .forUser(user)
//                .filter { $0.id != list.id }
//        return try listRepresentationsBuilder.build(on: request.eventLoop)
//            .flatMap { listRepresentations in


}
