import Vapor

import Foundation

extension Environment {

    /// Loads environment variables from .env files.
    public static func dotenv(filename: String = ".env") {
        guard let path = FileManager.default.absolutePathInWorkDir(for: filename) else {
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
