import Vapor

// MARK: - Keys

class ControllerParameterKeys {

    fileprivate init(rawValue: String) {
        self.rawValue = rawValue
    }

    var rawValue: String

}

final class ControllerParameterKey<ValueType>: ControllerParameterKeys,
        RawRepresentable,
        CustomStringConvertible
    where ValueType: ControllerParameterValue
{

    override init(rawValue: String) {
        super.init(rawValue: rawValue)
    }

    init(_ string: String) {
        super.init(rawValue: string)
    }

    // MARK: CustomStringConvertible

    var description: String {
        return rawValue
    }

}

// MARK: - Value

protocol ControllerParameterValue: Decodable {
    var stringValue: String { get }
}

extension RawRepresentable where RawValue == String {

    var stringValue: String {
        return rawValue
    }

}

extension String: ControllerParameterValue {

    var stringValue: String {
        return self
    }

}

// MARK: - Parameter

struct ControllerParameter {

    fileprivate var key: String
    fileprivate var value: ControllerParameterValue?

    init(key: String, _ value: ControllerParameterValue?) {
        self.key = key
        self.value = value
    }

    init(key: ControllerParameterKeys, _ value: ControllerParameterValue?) {
        self.key = key.rawValue
        self.value = value
    }

    static func value<T>(_ value: T, for key: ControllerParameterKey<T>) -> ControllerParameter {
        return ControllerParameter(key: key.rawValue, value)
    }

}

// MARK: -

extension Dictionary where Key == String, Value == String? {

    mutating func merge(_ parameter: ControllerParameter) {
        self[parameter.key] = parameter.value?.stringValue
    }

}
