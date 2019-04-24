import Random

extension Random.DataGenerator {

    public func generateToken() throws -> String {
        return try generateData(count: 16).base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }

}
