import Foundation

struct ValueValidator<T>: CustomStringConvertible {
    var readable: String

    private let closure: (T) throws -> Void

    init(_ readable: String, _ closure: @escaping (T) throws -> Void) {
        self.readable = readable
        self.closure = closure
    }

    func validate(_ data: T) throws {
        try closure(data)
    }

    // MARK: CustomStringConvertible

    var description: String {
        return readable
    }

}
