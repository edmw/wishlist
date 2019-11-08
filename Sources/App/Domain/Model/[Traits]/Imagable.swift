import Vapor

protocol Imageable {

    var imageableEntityGroupKey: String? { get }
    var imageableEntityKey: String? { get }

    var imageableSize: ImageableSize { get }

}

struct ImageableSize {

    var width: Int
    var height: Int

}

enum ImageableError: Error, Debuggable {

    case keyMissing(AnyKeyPath)
    case keyInvalid(AnyKeyPath)

    var identifier: String {
        switch self {
        case .keyMissing(let path): return "Key is missing for \(path)"
        case .keyInvalid(let path): return "Key is invalid for \(path)"
        }
    }

    var reason: String {
        switch self {
        case .keyMissing: return "Must not be nil"
        case .keyInvalid: return "Valid characters are [a-zA-Z0-9\\-]"
        }
    }

}
