import Foundation

// MARK: - Creation

extension URL {

    public init?(string: String?) {
        guard let string = string else {
            return nil
        }
        self.init(string: string)
    }

    public func urlByAppendingQueryItem(_ item: URLQueryItem) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        urlComponents.appendQueryItem(item)
        return urlComponents.url
    }

}

// MARK: - Validation

enum URLType {
    /// An absolute URL contains all the information necessary to locate a resource without
    /// a fragment identifier.
    case webAbsolute
    /// An absolute URL contains with en empty path:
    case webAbsolutePathEmpty
}

extension URL {

    func validate(is type: URLType) -> Bool {
        switch type {
        case .webAbsolute:
            return (scheme == "http" || scheme == "https")
                && host != nil
                && fragment == nil
        case .webAbsolutePathEmpty:
            return (scheme == "http" || scheme == "https")
                && host != nil
                && fragment == nil
                && path.isEmpty
        }
    }

}
