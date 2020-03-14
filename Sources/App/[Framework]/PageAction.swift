import Vapor

// MARK: PageAction

struct PageAction: Encodable {

    let reference: PageReference

    let method: PageReferenceMethod

    init(reference components: [PageReferenceComponentRepresentable], method: PageReferenceMethod) {
        self.reference = PageReference(components)
        self.method = method
    }

    static func get(_ link: PageReferenceComponentRepresentable...) -> Self {
        .init(reference: link, method: .GET)
    }

    static func post(_ link: PageReferenceComponentRepresentable...) -> Self {
        .init(reference: link, method: .POST)
    }

    static func put(_ link: PageReferenceComponentRepresentable...) -> Self {
        .init(reference: link, method: .PUT)
    }

    static func patch(_ link: PageReferenceComponentRepresentable...) -> Self {
        .init(reference: link, method: .PATCH)
    }

    static func delete(_ link: PageReferenceComponentRepresentable...) -> Self {
        .init(reference: link, method: .DELETE)
    }

}
