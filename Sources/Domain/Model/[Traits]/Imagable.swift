// MARK: Imageable

public protocol Imageable {

    var imageableEntityKey: String? { get }
    var imageableEntityGroupKeys: [String]? { get }

    var imageableSize: ImageableSize { get }

}

public struct ImageableSize {

    public var width: Int
    public var height: Int

}

public enum ImageableError: Error {

    case keyMissing(AnyKeyPath)
    case keyInvalid(AnyKeyPath)

}
