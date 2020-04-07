import Foundation
import NIO

// MARK: UserListsActor

/// Lists use cases for the user.
public protocol UserListsActor: Actor {

    func getLists(
        _ specification: GetLists.Specification,
        _ boundaries: GetLists.Boundaries
    ) throws -> EventLoopFuture<GetLists.Result>

    func createList(
        _ specification: CreateList.Specification,
        _ boundaries: CreateList.Boundaries
    ) throws -> EventLoopFuture<CreateList.Result>

    func requestListEditing(
        _ specification: RequestListEditing.Specification,
        _ boundaries: RequestListEditing.Boundaries
    ) throws -> EventLoopFuture<RequestListEditing.Result>

    func updateList(
        _ specification: UpdateList.Specification,
        _ boundaries: UpdateList.Boundaries
    ) throws -> EventLoopFuture<UpdateList.Result>

    func createOrUpdateList(
        _ specification: CreateOrUpdateList.Specification,
        _ boundaries: CreateOrUpdateList.Boundaries
    ) throws -> EventLoopFuture<CreateOrUpdateList.Result>

    func requestListDeletion(
        _ specification: RequestListDeletion.Specification,
        _ boundaries: RequestListDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestListDeletion.Result>

    func deleteList(
        _ specification: DeleteList.Specification,
        _ boundaries: DeleteList.Boundaries
    ) throws -> EventLoopFuture<DeleteList.Result>

    func requestListImport(
        _ specification: RequestListImportFromJSON.Specification,
        _ boundaries: RequestListImportFromJSON.Boundaries
    ) throws -> EventLoopFuture<RequestListImportFromJSON.Result>

    func importList(
        _ specification: ImportListFromJSON.Specification,
        _ boundaries: ImportListFromJSON.Boundaries
    ) throws -> EventLoopFuture<ImportListFromJSON.Result>

    func exportList(
        _ specification: ExportListToJSON.Specification,
        _ boundaries: ExportListToJSON.Boundaries
    ) throws -> EventLoopFuture<ExportListToJSON.Result>

}

/// This is the domain’s implementation of the Lists use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserListsActor: UserListsActor,
    CreateListActor,
    UpdateListActor,
    ImportListFromJSONActor,
    ExportListToJSONActor,
    SetupItemActor
{

    let userItemsActor: UserItemsActor

    let listRepository: ListRepository
    let itemRepository: ItemRepository
    let userRepository: UserRepository

    let logging: MessageLogging
    let recording: EventRecording

    let itemService: ItemService

    let listRepresentationsBuilder: ListRepresentationsBuilder

    public required init(
        userItemsActor: UserItemsActor,
        listRepository: ListRepository,
        itemRepository: ItemRepository,
        userRepository: UserRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.userItemsActor = userItemsActor
        self.listRepository = listRepository
        self.itemRepository = itemRepository
        self.userRepository = userRepository
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
        self.itemService = ItemService(itemRepository)
        self.listRepresentationsBuilder = .init(listRepository, itemRepository)
    }

}
