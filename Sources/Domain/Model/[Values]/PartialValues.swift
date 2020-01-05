import Foundation

// MARK: PartialValues

public struct PartialValues<Wrapped: Values>: Any,
    CustomStringConvertible,
    CustomDebugStringConvertible
{

    func updating(_ instanceOf: Wrapped) -> Wrapped {
        var instance = instanceOf
        for (keypath, value) in values {
            instance = keypath.applying(value as Any, to: instance)
        }
        return instance
    }

    enum Error<ValueType>: Swift.Error {
        case missingKey(KeyPath<Wrapped, ValueType>)
        case invalidValueType(key: KeyPath<Wrapped, ValueType>, actualValue: Any)
    }

    private var values: [WritableKeyPathApplicator<Wrapped>: Any?] = [:]

    private var wrapped: Wrapped?

    public init() {
        self.wrapped = nil
    }

    internal init(wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    func value<ValueType>(for key: WritableKeyPath<Wrapped, ValueType>) throws -> ValueType {
        if let value = values[WritableKeyPathApplicator(key)] {
            if let value = value as? ValueType {
                return value
            }
            else if let value = value {
                throw Error.invalidValueType(key: key, actualValue: value)
            }
        }
        else if let value = wrapped?[keyPath: key] {
            return value
        }

        throw Error.missingKey(key)
    }

    func value<ValueType>(for key: WritableKeyPath<Wrapped, ValueType?>) throws -> ValueType {
        if let value = values[WritableKeyPathApplicator(key)] {
            if let value = value as? ValueType {
                return value
            }
            else if let value = value {
                throw Error.invalidValueType(key: key, actualValue: value)
            }
        }
        else if let value = wrapped?[keyPath: key] {
            return value
        }

        throw Error.missingKey(key)
    }

    public subscript<ValueType>(key: WritableKeyPath<Wrapped, ValueType>) -> ValueType? {
        get {
            return try? value(for: key)
        }
        set {
            values.updateValue(newValue, forKey: WritableKeyPathApplicator(key))
        }
    }

    public subscript<ValueType>(key: WritableKeyPath<Wrapped, ValueType?>) -> ValueType? {
        get {
            return try? value(for: key)
        }
        set {
            values.updateValue(newValue, forKey: WritableKeyPathApplicator(key))
        }
    }

    public var description: String {
        let wrappedDescription: String

        if let wrapped = wrapped as? CustomStringConvertible {
            wrappedDescription = wrapped.description
        }
        else {
            wrappedDescription = String(describing: wrapped)
        }

        return "<\(type(of: self)) values=\(values.description);"
            + " wrapped=\(wrappedDescription)"
            + ">"
    }

    public var debugDescription: String {
        if let wrapped = wrapped {
            return debugDescription(utilising: wrapped)
        }
        else {
            return "<\(type(of: self)) values=\(values.debugDescription);"
                + " wrapped=\(wrapped.debugDescription))"
                + ">"
        }
    }

    func debugDescription(utilising instance: Wrapped) -> String {
        var namedValues: [String: Any] = [:]
        var unnamedValues: [WritableKeyPathApplicator<Wrapped>: Any] = [:]

        let mirror = Mirror(reflecting: instance)
        for (key, value) in self.values {
            var foundKey = false

            for child in mirror.children {
                if let propertyName = child.label {
                    foundKey = (value as AnyObject) === (child.value as AnyObject)

                    if foundKey {
                        namedValues[propertyName] = value
                        break
                    }
                }
            }

            if !foundKey {
                unnamedValues[key] = value
            }
        }
        return "<\(type(of: self))"
            + " values=\(namedValues.debugDescription), \(unnamedValues.debugDescription);"
            + " wrapped=\(wrapped.debugDescription))"
            + ">"
    }
}

// MARK: WritableKeyPathApplicator

private struct WritableKeyPathApplicator<Type>: Hashable {

    private let partialKeyPath: PartialKeyPath<Type>

    private let applicator: (Type, Any) -> Type

    init<ValueType>(_ keypath: WritableKeyPath<Type, ValueType>) {
        self.partialKeyPath = keypath
        self.applicator = {
            var instance = $0
            if let value = $1 as? ValueType {
                instance[keyPath: keypath] = value
            }
            return instance
        }
    }

    func applying(_ value: Any, to type: Type) -> Type {
        return applicator(type, value)
    }

    // Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(partialKeyPath)
    }

    // Equatable

    static func == (lhs: WritableKeyPathApplicator<Type>, rhs: WritableKeyPathApplicator<Type>)
        -> Bool
    {
        return lhs.partialKeyPath == rhs.partialKeyPath
    }

}
