import Foundation

class TestingFileManager: FileManager {

    public var files = [String]()

    public override func createFile(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey : Any]? = nil
    ) -> Bool {
        files.append(path)
        return true
    }

    public override func removeItem(atPath path: String) throws {
        files.removeAll { $0 == path }
    }

    public override func fileExists(atPath path: String) -> Bool {
        return files.filter { $0 == path }.isNotEmpty
    }

}
