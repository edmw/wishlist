import Foundation
import NIO

// MARK: ImageStoreProvider

public protocol ImageStoreProvider {

    /// Uploads a remote image and returns a local url.
    func storeImage(for imagable: Imageable, from url: URL)
        throws -> EventLoopFuture<ImageStoreLocator?>

    /// Removes all local images for the specified imagable.
    func removeImages(for imagable: Imageable) throws

    /// Remove the specified image from the image store.
    func removeImage(at imagestoreurl: ImageStoreLocator) throws

}
