import Vapor
import Fluent

extension EventLoopFuture where Expectation: Model {

    public func deleteModel(on connectable: DatabaseConnectable) -> EventLoopFuture<T> {
        return self.flatMap(to: T.self) { model in
            return model.delete(on: connectable).transform(to: model)
        }
    }

}
