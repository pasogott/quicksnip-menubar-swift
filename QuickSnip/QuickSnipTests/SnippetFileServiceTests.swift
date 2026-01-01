import XCTest
@testable import QuickSnip

final class SnippetFileServiceTests: XCTestCase {

    private var tempDirectory: URL!
    private var service: SnippetFileService!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        service = SnippetFileService(snippetsDirectory: tempDirectory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    // MARK: - Load Snippet Tree Tests

    func test_loadSnippetTree_returnsEmptyFolderForEmptyDirectory() throws {
        let folder = try service.loadSnippetTree()

        XCTAssertEqual(folder.snippets.count, 0)
        XCTAssertEqual(folder.children.count, 0)
    }

    func test_loadSnippetTree_loadsSnippetFromMarkdownFile() throws {
        let content = """
        ---
        shortcut: ;test
        ---
        Hello World
        """
        try content.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)

        let folder = try service.loadSnippetTree()

        XCTAssertEqual(folder.snippets.count, 1)
        XCTAssertEqual(folder.snippets.first?.shortcut, ";test")
        XCTAssertEqual(folder.snippets.first?.content, "Hello World")
    }

    func test_loadSnippetTree_ignoresNonMarkdownFiles() throws {
        try "some text".write(to: tempDirectory.appendingPathComponent("readme.txt"), atomically: true, encoding: .utf8)

        let folder = try service.loadSnippetTree()

        XCTAssertEqual(folder.snippets.count, 0)
    }

    func test_loadSnippetTree_loadsSubfolders() throws {
        let subfolder = tempDirectory.appendingPathComponent("work", isDirectory: true)
        try FileManager.default.createDirectory(at: subfolder, withIntermediateDirectories: true)

        let folder = try service.loadSnippetTree()

        XCTAssertEqual(folder.children.count, 1)
        XCTAssertEqual(folder.children.first?.name, "work")
    }

    func test_loadSnippetTree_loadsNestedSnippets() throws {
        let subfolder = tempDirectory.appendingPathComponent("work", isDirectory: true)
        try FileManager.default.createDirectory(at: subfolder, withIntermediateDirectories: true)

        let content = """
        ---
        shortcut: ;sig
        ---
        Best regards
        """
        try content.write(to: subfolder.appendingPathComponent("signature.md"), atomically: true, encoding: .utf8)

        let folder = try service.loadSnippetTree()

        XCTAssertEqual(folder.children.first?.snippets.count, 1)
        XCTAssertEqual(folder.children.first?.snippets.first?.shortcut, ";sig")
    }

    func test_loadSnippetTree_sortsFoldersAlphabetically() throws {
        try FileManager.default.createDirectory(at: tempDirectory.appendingPathComponent("zebra"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tempDirectory.appendingPathComponent("alpha"), withIntermediateDirectories: true)

        let folder = try service.loadSnippetTree()

        XCTAssertEqual(folder.children.map(\.name), ["alpha", "zebra"])
    }

    func test_loadSnippetTree_sortsSnippetsAlphabetically() throws {
        try "---\nshortcut: ;z\n---\nZ".write(to: tempDirectory.appendingPathComponent("zebra.md"), atomically: true, encoding: .utf8)
        try "---\nshortcut: ;a\n---\nA".write(to: tempDirectory.appendingPathComponent("alpha.md"), atomically: true, encoding: .utf8)

        let folder = try service.loadSnippetTree()

        XCTAssertEqual(folder.snippets.map(\.fileName), ["alpha", "zebra"])
    }

    // MARK: - Create Snippet Tests

    func test_createSnippet_createsFileOnDisk() throws {
        let rootFolder = try service.loadSnippetTree()

        _ = try service.createSnippet(named: "test", shortcut: ";test", in: rootFolder)

        let fileExists = FileManager.default.fileExists(atPath: tempDirectory.appendingPathComponent("test.md").path)
        XCTAssertTrue(fileExists)
    }

    func test_createSnippet_returnsSnippetWithCorrectShortcut() throws {
        let rootFolder = try service.loadSnippetTree()

        let snippet = try service.createSnippet(named: "greeting", shortcut: ";hi", in: rootFolder)

        XCTAssertEqual(snippet.shortcut, ";hi")
    }

    func test_createSnippet_sanitizesFileName() throws {
        let rootFolder = try service.loadSnippetTree()

        _ = try service.createSnippet(named: "test/with:slashes", shortcut: ";test", in: rootFolder)

        let fileExists = FileManager.default.fileExists(atPath: tempDirectory.appendingPathComponent("test-with-slashes.md").path)
        XCTAssertTrue(fileExists)
    }

    // MARK: - Create Folder Tests

    func test_createFolder_createsDirectoryOnDisk() throws {
        let rootFolder = try service.loadSnippetTree()

        _ = try service.createFolder(named: "work", in: rootFolder)

        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: tempDirectory.appendingPathComponent("work").path, isDirectory: &isDirectory)
        XCTAssertTrue(exists)
        XCTAssertTrue(isDirectory.boolValue)
    }

    func test_createFolder_returnsFolder() throws {
        let rootFolder = try service.loadSnippetTree()

        let folder = try service.createFolder(named: "personal", in: rootFolder)

        XCTAssertEqual(folder.name, "personal")
    }

    // MARK: - Delete Tests

    func test_deleteSnippet_removesFileFromDisk() throws {
        let content = "---\nshortcut: ;test\n---\nContent"
        let filePath = tempDirectory.appendingPathComponent("test.md")
        try content.write(to: filePath, atomically: true, encoding: .utf8)

        let folder = try service.loadSnippetTree()
        guard let snippet = folder.snippets.first else {
            XCTFail("Snippet should exist")
            return
        }

        try service.deleteSnippet(snippet)

        XCTAssertFalse(FileManager.default.fileExists(atPath: filePath.path))
    }

    func test_deleteFolder_removesDirectoryFromDisk() throws {
        let folderPath = tempDirectory.appendingPathComponent("toDelete")
        try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true)

        let rootFolder = try service.loadSnippetTree()
        guard let subfolder = rootFolder.children.first else {
            XCTFail("Subfolder should exist")
            return
        }

        try service.deleteFolder(subfolder)

        XCTAssertFalse(FileManager.default.fileExists(atPath: folderPath.path))
    }

    // MARK: - Edge Cases

    func test_loadSnippetTree_skipsInvalidMarkdownFiles() throws {
        // File without frontmatter
        try "Just plain text".write(to: tempDirectory.appendingPathComponent("invalid.md"), atomically: true, encoding: .utf8)

        let folder = try service.loadSnippetTree()

        XCTAssertEqual(folder.snippets.count, 0)
    }

    func test_loadSnippetTree_createsDirectoryIfNotExists() throws {
        let nonExistentDir = tempDirectory.appendingPathComponent("new_snippets")
        let newService = SnippetFileService(snippetsDirectory: nonExistentDir)

        _ = try newService.loadSnippetTree()

        XCTAssertTrue(FileManager.default.fileExists(atPath: nonExistentDir.path))
    }
}
