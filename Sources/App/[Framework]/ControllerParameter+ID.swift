import Vapor

extension ControllerParameterKeys {
    static let userID = ControllerParameterKey<ID>("userid")
    static let listID = ControllerParameterKey<ID>("listid")
    static let itemID = ControllerParameterKey<ID>("itemid")
}

extension ID: ControllerParameterValue {

    var stringValue: String {
        return string ?? ""
    }

}
