import Vapor

import Foundation

extension Environment {

    /// Loads environment variables from .env files.
    /// Files named '.env.<HOSTNAME>' take precedence over '.env'.
    public static func dotenv(filename: String = ".env") {
        var filepath: String?
        if let hostname = Host.current().localizedName {
            filepath = FileManager.default.absolutePathInWorkDir(for: "\(filename).\(hostname)")
        }
        if filepath == nil {
            filepath = FileManager.default.absolutePathInWorkDir(for: filename)
        }
        guard let path = filepath else {
            return
        }

        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }

        let lines = contents.split(whereSeparator: { $0 == "\n" || $0 == "\r\n" })
        for line in lines {
            let string = line.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !line.isEmpty else {
                continue
            }
            guard !line.starts(with: "#") else {
                continue
            }

            let parts = string.components(separatedBy: "=")

            guard parts.count == 2 else {
                continue
            }

            let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            var value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)

            if value.first == "\"" && value.last == "\"" {
                value = value.dropFirst().dropLast().replacingOccurrences(of: "\\\"", with: "\"")
            }

            setenv(key, value, 1)
        }
    }

}
