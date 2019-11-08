import Vapor

extension EventLoopFuture {

    public func catchMap<E>(
        _ type: E.Type,
        _ callback: @escaping (E) throws -> Expectation
    ) -> EventLoopFuture<Expectation> {
        return catchFlatMap { error in
            if let error = error as? E {
                let promise = self.eventLoop.newPromise(T.self)
                do {
                    try promise.succeed(result: callback(error))
                }
                catch {
                    promise.fail(error: error)
                }
                return promise.futureResult
            }
            return self
        }
    }

    public func catchFlatMap<E>(
        _ type: E.Type,
        _ callback: @escaping (E) throws -> EventLoopFuture<Expectation>
    ) -> EventLoopFuture<Expectation> {
        return catchFlatMap { error in
            if let error = error as? E {
                return try callback(error)
            }
            return self
        }
    }

}
