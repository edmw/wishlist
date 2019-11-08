import Vapor

import Foundation

protocol UserRepository: EntityRepository {

    func find(id: User.ID) -> EventLoopFuture<User?>
    func find(identification: Identification) -> EventLoopFuture<User?>
    func find(subjectId id: String) -> EventLoopFuture<User?>
    func find(nickName: String) -> EventLoopFuture<User?>

    func all() -> EventLoopFuture<[User]>

    func count(nickName: String) -> EventLoopFuture<Int>

    func save(user: User) -> EventLoopFuture<User>

}
