public protocol Imageable {

    var imageableEntityGroupKey: String? { get }
    var imageableEntityKey: String? { get }

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
