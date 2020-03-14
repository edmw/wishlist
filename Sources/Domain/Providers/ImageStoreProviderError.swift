// MARK: ImageStoreProviderError

public enum ImageStoreProviderError: Error {

    case imagableKeyMissing(AnyKeyPath)
    case imagableKeyInvalid(AnyKeyPath)

}
