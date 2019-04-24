import Vapor

extension ControllerParameterKeys {
    static let locator = ControllerParameterKey<Locator>("p")
}

extension Locator: ControllerParameterValue {

    var stringValue: String {
        return locationString
    }

}
