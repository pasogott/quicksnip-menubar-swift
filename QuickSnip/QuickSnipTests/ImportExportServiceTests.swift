import XCTest
@testable import QuickSnip

final class ImportExportServiceTests: XCTestCase {

    private var tempDirectory: URL!
    private var service: ImportExportService!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        service = ImportExportService(snippetsDirectory: tempDirectory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    // MARK: - Export Tests

    func test_exportToZip_createsZipFile() throws {
        let folder = SnippetFolder(name: "test", path: tempDirectory)
        let zipURL = tempDirectory.appendingPathComponent("export.zip")

        try service.exportToZip(folder: folder, destination: zipURL)

        XCTAssertTrue(FileManager.default.fileExists(atPath: zipURL.path))
    }

    func test_exportToZip_zipContainsContent() throws {
        try "content".write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        let folder = SnippetFolder(name: tempDirectory.lastPathComponent, path: tempDirectory)
        let zipURL = tempDirectory.appendingPathComponent("export.zip")

        try service.exportToZip(folder: folder, destination: zipURL)

        let zipData = try Data(contentsOf: zipURL)
        XCTAssertGreaterThan(zipData.count, 0)
    }

    // MARK: - Import Folder Tests

    func test_importFolder_copiesMarkdownFile() throws {
        let sourceDir = tempDirectory.appendingPathComponent("source")
        try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        try "content".write(to: sourceDir.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)

        let result = try service.importFolder(sourceDir)

        XCTAssertEqual(result.imported, 1)
        XCTAssertEqual(result.skipped, 0)
    }

    func test_importFolder_countsOnlyMarkdownFilesInFolder() throws {
        let sourceDir = tempDirectory.appendingPathComponent("source")
        try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        try "content".write(to: sourceDir.appendingPathComponent("readme.txt"), atomically: true, encoding: .utf8)

        let result = try service.importFolder(sourceDir)

        // Non-.md files in folders are copied but not counted
        XCTAssertEqual(result.imported, 0)
        XCTAssertEqual(result.skipped, 0)
    }

    func test_importFolder_countsNestedMarkdownFiles() throws {
        let sourceDir = tempDirectory.appendingPathComponent("source")
        let nestedDir = sourceDir.appendingPathComponent("nested")
        try FileManager.default.createDirectory(at: nestedDir, withIntermediateDirectories: true)
        try "content1".write(to: sourceDir.appendingPathComponent("a.md"), atomically: true, encoding: .utf8)
        try "content2".write(to: nestedDir.appendingPathComponent("b.md"), atomically: true, encoding: .utf8)

        let result = try service.importFolder(sourceDir)

        XCTAssertEqual(result.imported, 2)
    }

    func test_importFolder_createsUniqueNameForDuplicates() throws {
        // Create source directory outside of snippetsDirectory
        let externalDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: externalDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: externalDir) }

        let sourceDir = externalDir.appendingPathComponent("imported")
        try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        try "content".write(to: sourceDir.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)

        _ = try service.importFolder(sourceDir)
        _ = try service.importFolder(sourceDir)

        let contents = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        let folders = contents.filter { $0.lastPathComponent.hasPrefix("imported") }
        // Should have "imported" and "imported-1"
        XCTAssertEqual(folders.count, 2)
        XCTAssertTrue(folders.contains { $0.lastPathComponent == "imported" })
        XCTAssertTrue(folders.contains { $0.lastPathComponent == "imported-1" })
    }

    // MARK: - Import from Zip Tests

    func test_importFromZip_extractsAndCopiesFiles() throws {
        let sourceDir = tempDirectory.appendingPathComponent("source")
        try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)
        try "content".write(to: sourceDir.appendingPathComponent("snippet.md"), atomically: true, encoding: .utf8)

        let zipURL = tempDirectory.appendingPathComponent("test.zip")
        let folder = SnippetFolder(name: "source", path: sourceDir)
        try service.exportToZip(folder: folder, destination: zipURL)

        try FileManager.default.removeItem(at: sourceDir)

        let destDir = tempDirectory.appendingPathComponent("dest")
        try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)
        let destService = ImportExportService(snippetsDirectory: destDir)

        let result = try destService.importFromZip(zipURL)

        XCTAssertEqual(result.imported, 1)
    }

    func test_importFromZip_throwsForInvalidZip() throws {
        let invalidZip = tempDirectory.appendingPathComponent("invalid.zip")
        try "not a zip".write(to: invalidZip, atomically: true, encoding: .utf8)

        XCTAssertThrowsError(try service.importFromZip(invalidZip)) { error in
            XCTAssertEqual(error as? ImportExportError, .invalidZipFile)
        }
    }

    // MARK: - ImportResult Tests

    func test_importResult_description_noFilesToImport() {
        let result = ImportResult(imported: 0, skipped: 0)
        XCTAssertEqual(result.description, "No files to import")
    }

    func test_importResult_description_onlyImported() {
        let result = ImportResult(imported: 3, skipped: 0)
        XCTAssertEqual(result.description, "3 imported")
    }

    func test_importResult_description_onlySkipped() {
        let result = ImportResult(imported: 0, skipped: 2)
        XCTAssertEqual(result.description, "2 skipped")
    }

    func test_importResult_description_importedAndSkipped() {
        let result = ImportResult(imported: 5, skipped: 3)
        XCTAssertEqual(result.description, "5 imported, 3 skipped")
    }

    // MARK: - ImportExportError Tests

    func test_exportFailed_hasCorrectDescription() {
        let error = ImportExportError.exportFailed
        XCTAssertEqual(error.errorDescription, "Failed to create zip archive")
    }

    func test_invalidZipFile_hasCorrectDescription() {
        let error = ImportExportError.invalidZipFile
        XCTAssertEqual(error.errorDescription, "Invalid or corrupted zip file")
    }
}
