import DomainModel

import Foundation
import NIO

// MARK: PresentWishlist

public final class PresentWishlist: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: ActionSpecification, WishlistSpecification {
        public let identification: Identification
        public let listID: ListID
        public let sorting: ItemsSorting
        public let userID: UserID?
        public static func specification(
            _ listid: ListID,
            with sorting: ItemsSorting = .ascending(by: \Item.title),
            for identification: Identification,
            userBy userid: UserID?
        ) -> Self {
            return Self(
                identification: identification,
                listID: listid,
                sorting: sorting,
                userID: userid
            )
        }
    }

    // MARK: Result

    public struct Result {
        public let list: ListRepresentation
        public let items: [ItemRepresentation]
        public let isFavorite: Bool
        public let owner: UserRepresentation
        public let user: UserRepresentation?
        public let identification: Identification
    }

}

// MARK: - Actor

extension DomainWishlistActor {

    private func isFavorite(_ list: List, for user: User?) throws -> EventLoopFuture<Bool> {
        let favoriteRepository = self.favoriteRepository
        guard let user = user else {
            return favoriteRepository.future(false)
        }
        return try favoriteRepository.find(favorite: list, for: user).map { $0 != nil }
    }

    // MARK: presentWishlist

    public func presentWishlist(
        _ specification: PresentWishlist.Specification,
        _ boundaries: PresentWishlist.Boundaries
    ) throws -> EventLoopFuture<PresentWishlist.Result> {
        let itemRepository = self.itemRepository
        return authorizeOnWishlist(by: specification)
            .flatMap { authorization, identification in
                let list = authorization.entity
                let user = authorization.subject
                let owner = authorization.owner
                let sorting = specification.sorting
                return try ItemRepresentationsBuilder(itemRepository)
                    .forList(list)
                    .withSorting(sorting)
                    .build(on: boundaries.worker)
                    .and(self.isFavorite(list, for: user))
                    .map { arguments in let (items, isFavorite) = arguments
                        return .init(
                            list: list.representation,
                            items: items,
                            isFavorite: isFavorite,
                            owner: owner.representation,
                            user: user?.representation,
                            identification: identification
                        )
                    }
            }
    }

}
