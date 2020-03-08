@testable import Library
import XCTest
import Testing

final class FileManagerTests : XCTestCase, LibraryTestCase, HasAllTests {

    static var __allTests = [
        ("testCreateFile", testCreateFile),
        ("testCreateFileWithHTTP",testCreateFileWithHTTP),
        ("testRemoveFile",testRemoveFile),
        ("testRemoveFileWithHTTP",testRemoveFileWithHTTP),
        ("testAllTests", testAllTests)
    ]

    // FileManager extension adds a file creation function which allows to specify a
    // parent directory where files to be created must be contained in.
    func testCreateFile() throws {
        let filemanager = TestingFileManager()

        // parent directory
        let url = URL(string: "file:///foo/bar/")!
        // file to be created within parent directory
        let urlfile1 = URL(string: "file:///foo/bar/file")!
        // should succeed
        XCTAssertTrue(try filemanager.createFile(at: urlfile1, in: url))
        XCTAssertTrue(filemanager.files.contains(urlfile1.path))

        // file to be created outside parent directory
        let urlfile2 = URL(string: "file:///foo/file")!
        // should fail
        assert(
            try filemanager.createFile(at: urlfile2, in: url),
            throws: FileManagerError.invalidURL(urlfile2)
        )

        // file to be created outside parent directory
        let urlfile3 = URL(string: "file:///foo/bur/file")!
        // should fail
        assert(
            try filemanager.createFile(at: urlfile3, in: url),
            throws: FileManagerError.invalidURL(urlfile3)
        )
    }

    // FileManager extension adds a file creation function which works on file urls, only.
    func testCreateFileWithHTTP() throws {
        let filemanager = TestingFileManager()

        // try to create file with http scheme
        let url1 = URL(string: "file:///foo/bar/")!
        let urlfile1 = URL(string: "http:///foo/bar/file")!
        assert(
            try filemanager.createFile(at: urlfile1, in: url1),
            throws: FileManagerError.invalidScheme(urlfile1)
        )

        // try to create file within parent with http scheme
        let url2 = URL(string: "http:///foo/bar/")!
        let urlfile2 = URL(string: "file:///foo/bar/file")!
        assert(
            try filemanager.createFile(at: urlfile2, in: url2),
            throws: FileManagerError.invalidScheme(url2)
        )
    }

    // FileManager extension adds a file removal function which allows to specify a
    // parent directory where files to be removed must be contained in.
    func testRemoveFile() throws {
        let filemanager = TestingFileManager()
        let root = URL(string: "file:///")!

        // parent directory
        let url = URL(string: "file:///foo/bar/")!
        // file to be removed within parent directory
        let urlfile1 = URL(string: "file:///foo/bar/file")!
        // create file
        XCTAssertTrue(try filemanager.createFile(at: urlfile1, in: root))
        // should succeed
        try filemanager.removeFile(at: urlfile1, in: url)
        XCTAssertFalse(filemanager.files.contains(urlfile1.path))

        // file to be removed outside parent directory
        let urlfile2 = URL(string: "file:///foo/file")!
        // create file
        XCTAssertTrue(try filemanager.createFile(at: urlfile2, in: root))
        // should fail
        assert(
            try filemanager.removeFile(at: urlfile2, in: url),
            throws: FileManagerError.invalidURL(urlfile2)
        )
        XCTAssertTrue(filemanager.files.contains(urlfile2.path))

        // file to be removed outside parent directory
        let urlfile3 = URL(string: "file:///foo/bur/file")!
        // create file
        XCTAssertTrue(try filemanager.createFile(at: urlfile3, in: root))
        // should fail
        assert(
            try filemanager.removeFile(at: urlfile3, in: url),
            throws: FileManagerError.invalidURL(urlfile3)
        )
        XCTAssertTrue(filemanager.files.contains(urlfile3.path))
    }

    // FileManager extension adds a file removal function which works on file urls, only.
    func testRemoveFileWithHTTP() throws {
        let filemanager = TestingFileManager()
        let root = URL(string: "file:///")!

        // try to remove file with http scheme
        let url1 = URL(string: "file:///foo/bar/")!
        let urlfile1 = URL(string: "http:///foo/bar/file")!
        assert(
            try filemanager.removeFile(at: urlfile1, in: url1),
            throws: FileManagerError.invalidScheme(urlfile1)
        )

        // try to remove file within parent with http scheme
        let url2 = URL(string: "http:///foo/bar/")!
        let urlfile2 = URL(string: "file:///foo/bar/file")!
        XCTAssertTrue(try filemanager.createFile(at: urlfile2, in: root))
        assert(
            try filemanager.removeFile(at: urlfile2, in: url2),
            throws: FileManagerError.invalidScheme(url2)
        )
        XCTAssertTrue(filemanager.files.contains(urlfile2.path))

    }

    func testAllTests() throws {
        assertAllTests()
    }

}
