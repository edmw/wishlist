import Vapor

extension Session {

    func setLocator(_ locator: Locator, for key: LocatorKey) {
        self["_p_\(key.string)"] = locator.locationString
    }

    func getLocator(for key: LocatorKey, is type: LocatorType = .any) -> Locator? {
        guard let parameter = self["_p_\(key.string)"] else {
            return nil
        }
        guard let locator = Locator(string: parameter) else {
            return nil
        }
        switch type {
        case .local:
            return locator.isLocal ? locator : nil
        default:
            return locator
        }
    }

}
