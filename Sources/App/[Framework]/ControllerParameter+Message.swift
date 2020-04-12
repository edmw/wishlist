import Vapor

extension ControllerParameterKeys {
    static let message = ControllerParameterKey<ControllerParameterMessageValue>("m")
}

struct ControllerParameterMessageValue: RawRepresentable, ControllerParameterValue {

    var rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    init(rawValue: String) {
        self.rawValue = rawValue
    }

}
