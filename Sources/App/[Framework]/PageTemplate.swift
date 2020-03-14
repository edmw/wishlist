// MARK: PageTemplate

struct PageTemplate: ExpressibleByStringLiteral {

    let name: String
    let isLocalized: Bool

    init(name: String, isLocalized: Bool) {
        self.name = name
        self.isLocalized = isLocalized
    }

    init(stringLiteral value: StringLiteralType) {
        self.name = value
        self.isLocalized = false
    }

}
