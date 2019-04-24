import Vapor

extension Future {

    public func catchFlatMap<E>(
        _ type: E.Type,
        _ callback: @escaping (E) throws -> (Future<Expectation>)
    ) -> Future<Expectation> {
        return catchFlatMap { error in
            if let error = error as? E {
                return try callback(error)
            }
            return self
        }
    }

}
