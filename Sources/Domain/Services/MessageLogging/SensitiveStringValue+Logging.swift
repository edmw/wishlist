import Foundation

extension SensitiveStringValue {

    // MARK: Encodable

    /// Encodes this value into the given encoder.
    /// - Parameter encoder: The encoder to write data to.
    ///
    /// If the encoder is configured to encode for logging, the value will be shortened for
    /// privacy and security reasons.
    public func encode(to encoder: Encoder) throws {
        let string: String
        if encoder.isLogging {
            // this value is security sensitive
            // if it has to be encoded for logging,
            // strip some information from the real value
            string = rawValue.replacingCharacters(everyNth: 3, with: "-")
        }
        else {
            string = rawValue
        }
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }

}
