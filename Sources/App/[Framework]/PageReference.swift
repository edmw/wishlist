import Domain

// MARK: PageReference

struct PageReference {

    var components: [PageReferenceComponent]

    init(_ components: [PageReferenceComponent]) {
        self.components = components
    }

    init(_ components: [PageReferenceComponentRepresentable]) {
        self.components = components.map { $0.pageReferenceComponent }
    }

}

// MARK: PageReferenceComponent

enum PageReferenceComponent: PageReferenceComponentRepresentable, ExpressibleByStringLiteral {

    var pageReferenceComponent: PageReferenceComponent { self }

    case none
    case string(String)
    case identifier(AnyIdentifier)

    public init(stringLiteral value: String) {
        self = .string(value)
    }

}

// MARK: PageReferenceComponentRepresentable

protocol PageReferenceComponentRepresentable {
    var pageReferenceComponent: PageReferenceComponent { get }
}

extension String: PageReferenceComponentRepresentable {
    var pageReferenceComponent: PageReferenceComponent { .string(self) }
}

extension UserID: PageReferenceComponentRepresentable {
    var pageReferenceComponent: PageReferenceComponent { .identifier(self) }
}

extension ListID: PageReferenceComponentRepresentable {
    var pageReferenceComponent: PageReferenceComponent { .identifier(self) }
}

extension ItemID: PageReferenceComponentRepresentable {
    var pageReferenceComponent: PageReferenceComponent { .identifier(self) }
}

extension Optional: PageReferenceComponentRepresentable where Wrapped: Identifier {
    var pageReferenceComponent: PageReferenceComponent {
        guard let wrapped = self.wrapped else {
            return .none
        }
        return .identifier(wrapped)
    }
}
