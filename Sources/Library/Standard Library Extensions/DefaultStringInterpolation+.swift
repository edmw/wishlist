// MARK: DefaultStringInterpolation

extension DefaultStringInterpolation {

    public mutating func appendInterpolation<T>(optional: T?) {
        appendInterpolation(String(describing: optional))
    }

}
