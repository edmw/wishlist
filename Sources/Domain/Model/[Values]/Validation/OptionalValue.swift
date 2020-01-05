import Foundation

protocol OptionalValue: AnyOptionalValue {
    associatedtype WrappedValue

    var wrappedValue: WrappedValue? { get }

    static func makeOptionalValue(_ wrappedValue: WrappedValue?) -> Self
}

extension Optional: OptionalValue {
    typealias WrappedValue = Wrapped

    var wrappedValue: WrappedValue? {
        switch self {
        case .none: return nil
        case .some(let wrapped): return wrapped
        }
    }

    static func makeOptionalValue(_ wrapped: Wrapped?) -> Wrapped? {
        return wrapped
    }
}

protocol AnyOptionalValue {
    var anyWrappedValue: Any? { get }

    static var anyWrappedValue: Any.Type { get }
}

extension AnyOptionalValue where Self: OptionalValue {
    var anyWrappedValue: Any? { return wrappedValue }

    static var anyWrappedValue: Any.Type { return WrappedValue.self }
}
