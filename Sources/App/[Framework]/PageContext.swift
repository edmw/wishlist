import Domain

import Vapor

protocol PageContext: Encodable {
}

struct AnyPageContext: PageContext {

    // MARK: Encodable

    private var encodeFunc: (Encoder) throws -> Void

    init(_ pageContext: PageContext) {
        func encode(to encoder: Encoder) throws {
            try pageContext.encode(to: encoder)
        }
        self.encodeFunc = encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }

}
