import Domain

// MARK: PageReference

struct PageReference: Encodable {

    var components: [PageReferenceComponent]

    var path: String {
        "/" + components.map { component in
            switch component {
            case .none:
                return ""
            case .string(let value):
                return value
            case .identifier(let value):
                return String(describing: value)
            }
        }
        .joined(separator: "/")
    }

    init(_ components: [PageReferenceComponent]) {
        self.components = components
    }

    init(_ components: [PageReferenceComponentRepresentable]) {
        self.components = components.map { $0.pageReferenceComponent }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(path)
    }

}

// MARK: PageReferenceComponent

enum PageReferenceComponent: PageReferenceComponentRepresentable,
    ExpressibleByStringLiteral
{

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
