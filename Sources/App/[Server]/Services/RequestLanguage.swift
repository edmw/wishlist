struct RequestLanguage: CustomStringConvertible {

    let code: String
    let region: String?
    let script: String?
    let quality: Float

    init(
        _ code: String,
        _ region: String? = nil,
        _ script: String? = nil,
        _ quality: Float = 1.0
    ) {
        self.code = code
        self.region = region
        self.script = script
        self.quality = quality
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "Language(\(code)"
            + (region != nil ? ", region: \(region ??? "")" : "")
            + (script != nil ? ", script: \(script ??? ""))" : "")
            + ", quality: \(quality))"
    }

}
