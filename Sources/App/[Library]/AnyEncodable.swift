import Foundation

struct AnyEncodable: Encodable {

    var encodeFunc: (Encoder) throws -> Void

    init(_ encodable: Encodable) {
        func encode(to encoder: Encoder) throws {
            try encodable.encode(to: encoder)
        }
        self.encodeFunc = encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }

}
