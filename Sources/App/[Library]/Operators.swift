// swiftlint:disable static_operator

func ???? <T>(optional: T??, defaultValue: @autoclosure () -> T) -> T {
    return optional.flatMap { $0 } ?? defaultValue()
}
infix operator ????: NilCoalescingPrecedence
