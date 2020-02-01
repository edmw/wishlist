import NIO

// MARK: ListRepository

public final class ListsSorting: EntitySorting<List> {}

public protocol ListRepository: EntityRepository {

    var sortingDefault: ListsSorting { get }

    func find(by id: ListID) -> EventLoopFuture<List?>
    func find(by id: ListID, for user: User) throws -> EventLoopFuture<List?>
    func find(title: Title) -> EventLoopFuture<List?>
    func find(title: Title, for user: User) throws -> EventLoopFuture<List?>

    func findWithUser(by id: ListID, for userid: UserID)
        throws -> EventLoopFuture<(List, User)?>

    func all() -> EventLoopFuture<[List]>
    func all(for user: User) throws -> EventLoopFuture<[List]>
    func all(for user: User, sort: ListsSorting) throws -> EventLoopFuture<[List]>

    func count(for user: User) throws -> EventLoopFuture<Int>
    func count(title: Title, for user: User) throws -> EventLoopFuture<Int>

    func owner(of list: List) -> EventLoopFuture<User>

    func save(list: List) -> EventLoopFuture<List>

    func delete(list: List, for user: User) throws -> EventLoopFuture<List?>

    // Returns an available list title for a user based on the specified title.
    func available(title: String, for user: User) throws -> EventLoopFuture<String?>

}

extension ListRepository {

    public var sortingDefault: ListsSorting {
        return ListsSorting(\List.title, .ascending)
    }

}
