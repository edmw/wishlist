import Domain

extension PushoverUser {

    /// Mapping from `PushoverKey` to `PushoverUser`. `PushoverKey` is the value type used in the
    /// domain layer, while `PushoverUser` is the type used in the app.
    init(key: PushoverKey) {
        self.init(String(key))
    }

}
