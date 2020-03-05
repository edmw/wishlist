import Vapor

struct PageAction {

    let reference: PageReference

    let method: HTTPMethod

    init(reference components: [PageReferenceComponentRepresentable], method: HTTPMethod) {
        self.reference = PageReference(components)
        self.method = method
    }

    static func patch(_ link: PageReferenceComponentRepresentable...) -> Self {
        .init(reference: link, method: .PATCH)
    }

}
