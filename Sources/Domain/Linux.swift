// sourcery:inline:DomainStringValue.Linux
#if os(Linux)

// MARK: DO NOT EDIT

// Explicit implementation for conformance with
// - `ExpressibleByStringLiteral`
// - `LosslessStringConvertible`
// - `Collection`

// MARK: EmailSpecification

extension EmailSpecification {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

// MARK: FileName

extension FileName {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

// MARK: InvitationCode

extension InvitationCode {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

// MARK: LanguageTag

extension LanguageTag {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

// MARK: PushoverKey

extension PushoverKey {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

// MARK: Text

extension Text {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

// MARK: Title

extension Title {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

// MARK: UserIdentity

extension UserIdentity {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

// MARK: UserIdentityProvider

extension UserIdentityProvider {

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    public init(_ description: String) {
        self.init(string: description)
    }

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

}

#endif
// sourcery:end
