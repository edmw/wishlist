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

        for record in parseRecords(of: contents) {
            setenv(record.key, record.value, 1)
        }
    }

    public struct Record {
        let key: String
        let value: String
    }

    public static func parseRecords(of contents: String) -> [Record] {
        var records = [Record]()

        let lines = contents.split(whereSeparator: { $0 == "\n" || $0 == "\r\n" })
        for line in lines {
            let string = line.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !string.isEmpty else {
                continue
            }
            guard !string.starts(with: "#") else {
                continue
            }

            let parts = string
                .split(
                    separator: "=",
                    maxSplits: 1,
                    omittingEmptySubsequences: false
                )
                .map(String.init)

            guard parts.count == 2 else {
                continue // this is a syntax error which will be silently ignored for now
            }

            let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            var value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)

            guard !key.isEmpty else {
                continue // this is a syntax error which will be silently ignored for now
            }

            if value.first == "'" && value.last == "'" {
                value = String(value.dropFirst().dropLast())
            }
            else if value.first == "\"" && value.last == "\"" {
                value = value
                    .dropFirst()
                    .dropLast()
                    .replacingOccurrences(of: "\\n", with: "\n")
                    .replacingOccurrences(of: "\\\"", with: "\"")
            }

            records.append(.init(key: key, value: value))
        }

        return records
    }

}
