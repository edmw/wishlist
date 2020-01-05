import Foundation
import NIO

// MARK: UserItemsActor

/// Items use cases for the user.
public protocol UserItemsActor {

    func getItems(
        _ specification: GetItems.Specification,
        _ boundaries: GetItems.Boundaries
    ) throws -> EventLoopFuture<GetItems.Result>

    func createItem(
        _ specification: CreateItem.Specification,
        _ boundaries: CreateItem.Boundaries
    ) throws -> EventLoopFuture<CreateItem.Result>

    func requestItemEditing(
          _ specification: RequestItemEditing.Specification,
          _ boundaries: RequestItemEditing.Boundaries
    ) throws -> EventLoopFuture<RequestItemEditing.Result>

    func updateItem(
        _ specification: UpdateItem.Specification,
        _ boundaries: UpdateItem.Boundaries
    ) throws -> EventLoopFuture<UpdateItem.Result>

    func createOrUpdateItem(
        _ specification: CreateOrUpdateItem.Specification,
        _ boundaries: CreateOrUpdateItem.Boundaries
    ) throws -> EventLoopFuture<CreateOrUpdateItem.Result>

    func requestItemDeletion(
        _ specification: RequestDeletionEditing.Specification,
        _ boundaries: RequestDeletionEditing.Boundaries
    ) throws -> EventLoopFuture<RequestDeletionEditing.Result>

    func deleteItem(
        _ specification: DeleteItem.Specification,
        _ boundaries: DeleteItem.Boundaries
    ) throws -> EventLoopFuture<DeleteItem.Result>

}

/// Errors thrown by the User Items actor.
public enum UserItemsActorError: Error {
    case invalidUser
    case invalidList
    case invalidItem
    case validationError(
        UserRepresentation, ListRepresentation, ItemRepresentation?, ValuesError<ItemValues>
    )
    case itemIsReserved
}

/// This is the domain’s implementation of the Items use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserItemsActor: UserItemsActor,
    CreateItemActor,
    UpdateItemActor
{

    let itemRepository: ItemRepository
    let listRepository: ListRepository
    let userRepository: UserRepository

    let logging: MessageLoggingProvider
    let recording: EventRecordingProvider

    let itemRepresentationsBuilder: ItemRepresentationsBuilder

    public required init(
        _ itemRepository: ItemRepository,
        _ listRepository: ListRepository,
        _ userRepository: UserRepository,
        _ logging: MessageLoggingProvider,
        _ recording: EventRecordingProvider
    ) {
        self.itemRepository = itemRepository
        self.userRepository = userRepository
        self.listRepository = listRepository
        self.logging = logging
        self.recording = recording
        self.itemRepresentationsBuilder = .init(itemRepository)
    }

}
