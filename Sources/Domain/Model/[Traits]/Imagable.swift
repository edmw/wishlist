// MARK: Imageable

public protocol Imageable {

    var imageableEntityKey: String? { get }
    var imageableEntityGroupKeys: [String]? { get }

    var imageableSize: ImageableSize { get }

}
