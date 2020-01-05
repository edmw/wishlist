import Foundation
import NIO

// MARK: ImageStoreProvider

public protocol ImageStoreProvider {

    /// Uploads a remote image and returns a local url.
    func storeImage(for imagable: Imageable, from url: URL) throws -> EventLoopFuture<URL?>

    /// Removes all local images for the specified imagable.
    func removeImages(for imagable: Imageable) throws

}
