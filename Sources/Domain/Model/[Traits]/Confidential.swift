// MARK: Confidental

public protocol Confidental {

    /// Type alias for the key path to the id for this entities’ confidant user.
    typealias ConfidantUserID = WritableKeyPath<Self, UserID>

    /// Key path to this entities’ confidant user id.
    static var confidantUserID: ConfidantUserID { get }

}
