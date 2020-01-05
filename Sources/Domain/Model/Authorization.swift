import Foundation

struct Authorization<T> {
    let entity: T
    let owner: User
    let subject: User?
}
