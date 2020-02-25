import Library

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
        var description = "Language(\(code)"
        if let region = region {
            description += ", region: \(region)"
        }
        if let script = script {
            description += ", script: \(script)"
        }
        description += String(format: ", quality: %.1f", quality)
        description += ")"
        return description
    }

}
