import Foundation
import NIO

public protocol UserRepository: EntityRepository {

    func find(id: UserID) -> EventLoopFuture<User?>
    func findIf(id: UserID?) -> EventLoopFuture<User?>

    func find(identification: Identification) -> EventLoopFuture<User?>
    func find(identity: UserIdentity, of provider: UserIdentityProvider) -> EventLoopFuture<User?>

    func find(nickName: String) -> EventLoopFuture<User?>

    func all() -> EventLoopFuture<[User]>

    func count() -> EventLoopFuture<Int>
    func count(nickName: String) -> EventLoopFuture<Int>

    func save(user: User) -> EventLoopFuture<User>

}
