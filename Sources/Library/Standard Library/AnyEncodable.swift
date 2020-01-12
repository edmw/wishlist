import Foundation

public struct AnyEncodable: Encodable {

    private var encodeFunc: (Encoder) throws -> Void

    public init(_ encodable: Encodable) {
        func encode(to encoder: Encoder) throws {
            try encodable.encode(to: encoder)
        }
        self.encodeFunc = encode
    }

    public func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }

}
