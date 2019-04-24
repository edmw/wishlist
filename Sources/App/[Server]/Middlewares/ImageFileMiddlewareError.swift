import Vapor

enum ImageFileMiddlewareError: Error, Debuggable {

    case invalidFileURL(URL)

    var identifier: String {
        switch self {
        case .invalidFileURL: return "invalidFileURL"
        }
    }

    var reason: String {
        switch self {
        case .invalidFileURL(let url):
            return "Invalid file URL '\(url)'"
        }
    }

}
