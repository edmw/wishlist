/// Optional-string-coalescing operator
///
/// The ??? operator takes any Optional on its left side and a default string value on the right,
/// returning a string. If the optional value is non-nil, it unwraps it and returns its string
/// description, otherwise it returns the default value.
// swiftlint:disable static_operator
public func ??? <T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    return optional.map { String(describing: $0) } ?? defaultValue()
}
infix operator ???: NilCoalescingPrecedence

public func ???? <T>(optional: T??, defaultValue: @autoclosure () -> T) -> T {
    return optional.flatMap { $0 } ?? defaultValue()
}
infix operator ????: NilCoalescingPrecedence
