import Foundation

protocol ValueValidatable {

    static func valueValidations() throws -> ValueValidations<Self>

}

extension ValueValidatable {

    func validateValues() throws {
        try Self.valueValidations().run(on: self)
    }

}
