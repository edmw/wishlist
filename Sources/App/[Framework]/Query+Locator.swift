import Vapor

extension QueryContainer {

    func getLocator(is type: LocatorType = .any) -> Locator? {
        guard let locator = self[.locator] else {
            return nil
        }
        switch type {
        case .local:
            return locator.isLocal ? locator : nil
        case .any:
            return locator
        }
    }

}
