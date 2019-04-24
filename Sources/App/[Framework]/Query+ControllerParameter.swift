import Vapor

extension QueryContainer {

    subscript<T>(_ key: ControllerParameterKey<T>) -> T? {
        return self[T.self, at: key]
    }

    func get<T>(_ key: ControllerParameterKey<T>) throws -> T {
        return try get(T.self, at: key)
    }

}

extension ControllerParameterKey: BasicKeyRepresentable {

    func makeBasicKey() -> BasicKey {
        return BasicKey(rawValue)
    }

}
