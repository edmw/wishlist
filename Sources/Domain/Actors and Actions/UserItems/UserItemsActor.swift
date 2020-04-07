import Foundation
import NIO

// MARK: UserItemsActor

/// Items use cases for the user.
public protocol UserItemsActor: Actor {

    func getItems(
        _ specification: GetItems.Specification,
        _ boundaries: GetItems.Boundaries
    ) throws -> EventLoopFuture<GetItems.Result>

    func createItem(
        _ specification: CreateItem.Specification,
        _ boundaries: CreateItem.Boundaries
    ) throws -> EventLoopFuture<CreateItem.Result>

    func setupItem(
        _ specification: SetupItem.Specification,
        _ boundaries: SetupItem.Boundaries
    ) throws -> EventLoopFuture<SetupItem.Result>

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

    func requestItemManagement(
        _ specification: RequestItemManagement.Specification,
        _ boundaries: RequestItemManagement.Boundaries
    ) throws -> EventLoopFuture<RequestItemManagement.Result>

    func requestItemDeletion(
        _ specification: RequestItemDeletion.Specification,
        _ boundaries: RequestItemDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestItemDeletion.Result>

    func deleteItem(
        _ specification: DeleteItem.Specification,
        _ boundaries: DeleteItem.Boundaries
    ) throws -> EventLoopFuture<DeleteItem.Result>

    func requestItemMovement(
        _ specification: RequestItemMovement.Specification,
        _ boundaries: RequestItemMovement.Boundaries
    ) throws -> EventLoopFuture<RequestItemMovement.Result>

    func moveItem(
        _ specification: MoveItem.Specification,
        _ boundaries: MoveItem.Boundaries
    ) throws -> EventLoopFuture<MoveItem.Result>

    func requestItemReceiving(
        _ specification: RequestItemReceiving.Specification,
        _ boundaries: RequestItemReceiving.Boundaries
    ) throws -> EventLoopFuture<RequestItemReceiving.Result>

    func receiveItem(
        _ specification: ReceiveItem.Specification,
        _ boundaries: ReceiveItem.Boundaries
    ) throws -> EventLoopFuture<ReceiveItem.Result>

    func archiveItem(
        _ specification: ArchiveItem.Specification,
        _ boundaries: ArchiveItem.Boundaries
    ) throws -> EventLoopFuture<ArchiveItem.Result>

    func unarchiveItem(
        _ specification: UnarchiveItem.Specification,
        _ boundaries: UnarchiveItem.Boundaries
    ) throws -> EventLoopFuture<ArchiveItem.Result>

}

/// This is the domain’s implementation of the Items use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserItemsActor: UserItemsActor,
    CreateItemActor,
    UpdateItemActor,
    MoveItemActor,
    ReceiveItemActor,
    ArchiveItemActor,
    UnarchiveItemActor,
    SetupItemActor
{

    let itemRepository: ItemRepository
    let listRepository: ListRepository
    let userRepository: UserRepository
    let reservationRepository: ReservationRepository

    let logging: MessageLogging
    let recording: EventRecording

    let itemRepresentationsBuilder: ItemRepresentationsBuilder
    let listRepresentationsBuilder: ListRepresentationsBuilder

    public required init(
        itemRepository: ItemRepository,
        listRepository: ListRepository,
        userRepository: UserRepository,
        reservationRepository: ReservationRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.itemRepository = itemRepository
        self.userRepository = userRepository
        self.listRepository = listRepository
        self.reservationRepository = reservationRepository
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
        self.itemRepresentationsBuilder = .init(itemRepository)
        self.listRepresentationsBuilder = .init(listRepository, itemRepository)
    }

}
