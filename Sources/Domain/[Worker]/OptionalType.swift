import Foundation

protocol OptionalType: AnyOptionalType {

    associatedtype WrappedType

    var wrapped: WrappedType? { get }

}

extension Optional: OptionalType {

    typealias WrappedType = Wrapped

    var wrapped: Wrapped? {
        switch self {
        case .none: return nil
        case .some(let wrapped): return wrapped
        }
    }

}

protocol AnyOptionalType {

    var anyWrapped: Any? { get }

    static var anyWrappedType: Any.Type { get }

}

extension AnyOptionalType where Self: OptionalType {

    var anyWrapped: Any? { return wrapped }

    static var anyWrappedType: Any.Type { return WrappedType.self }

}
