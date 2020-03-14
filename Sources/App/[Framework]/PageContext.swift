import Domain

import Vapor

protocol PageContext: Encodable {

    var actions: PageActions { get }

}

struct AnyPageContext: PageContext {

    private let actionsVar: () -> PageActions

    private let encodeFunc: (Encoder) throws -> Void

    init(_ pageContext: PageContext) {
        self.actionsVar = { pageContext.actions }
        func encode(to encoder: Encoder) throws {
            try pageContext.encode(to: encoder)
        }
        self.encodeFunc = encode
    }

    var actions: PageActions { actionsVar() }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }

}
