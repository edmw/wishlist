import NIO

// MARK: EntityRepository

public protocol EntityRepository {

    func future<T>(_ value: T) -> EventLoopFuture<T>

    func future<T>(error: Error) -> EventLoopFuture<T>

}
