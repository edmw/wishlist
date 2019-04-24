import Foundation

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

extension FileManager {

    /// Determine absolute path of the given argument relative to the current working directory.
    /// - Parameter relativePath: relative path of the file.
    /// - Returns: the absolute path if exists.
    func absolutePathInWorkDir(for path: String) -> String? {

        // current working directory
        let cwd = getcwd(nil, Int(PATH_MAX))
        defer {
            free(cwd)
        }

        // actual working directory
        var awd: String?
        #if Xcode
            // attempt to find working directory through #file
            let file = #file
            awd = file.components(separatedBy: "/Sources").first
        #endif

        if awd == nil {
            if let cwd = cwd, let string = String(validatingUTF8: cwd) {
                awd = string
            }
            else {
                awd = "."
            }
        }
        awd = awd?.finished(with: "/")

        guard let workingDirectory = awd else {
            return nil
        }

        let absolutePath = workingDirectory + path
        guard fileExists(atPath: absolutePath) else {
            return nil
        }

        return absolutePath
    }

}
