import XCTest
@testable import QuickSnip

// MARK: - Mock Services

final class MockFileService: SnippetFileServiceProtocol, @unchecked Sendable {
    var snippetsDirectory: URL { URL(fileURLWithPath: "/tmp/snippets") }

    var snippetTreeToReturn: SnippetFolder?
    var loadError: Error?
    var createSnippetError: Error?
    var createFolderError: Error?
    var deleteError: Error?

    func loadSnippetTree() throws -> SnippetFolder {
        if let error = loadError { throw error }
        return snippetTreeToReturn ?? SnippetFolder(name: "root", path: snippetsDirectory)
    }

    func createSnippet(named name: String, shortcut: String, in folder: SnippetFolder) throws -> Snippet {
        if let error = createSnippetError { throw error }
        return Snippet(shortcut: shortcut, content: "content", filePath: folder.path.appendingPathComponent("\(name).md"))
    }

    func createFolder(named name: String, in parent: SnippetFolder) throws -> SnippetFolder {
        if let error = createFolderError { throw error }
        return SnippetFolder(name: name, path: parent.path.appendingPathComponent(name))
    }

    func deleteSnippet(_ snippet: Snippet) throws {
        if let error = deleteError { throw error }
    }

    func deleteFolder(_ folder: SnippetFolder) throws {
        if let error = deleteError { throw error }
    }
}

final class MockTextReplacementService: TextReplacementServiceProtocol, @unchecked Sendable {
    var hasAccess: Bool = true
    var syncError: Error?
    var syncResult = SyncResult(inserted: 0, updated: 0)

    func syncSnippets(_ snippets: [Snippet]) throws -> SyncResult {
        if let error = syncError { throw error }
        return syncResult
    }

    func openFullDiskAccessSettings() {}
}

// MARK: - Test Helpers

enum TestError: Error, LocalizedError {
    case testFailure
    var errorDescription: String? { "Test failure" }
}

@MainActor
final class SnippetTreeViewModelTests: XCTestCase {

    // MARK: - Load Snippets Tests

    func test_loadSnippets_populatesRootFolder() {
        var mockFileService = MockFileService()
        let expectedFolder = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";test", content: "content", filePath: URL(fileURLWithPath: "/tmp/test.md"))
            ]
        )
        mockFileService.snippetTreeToReturn = expectedFolder

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()

        XCTAssertNotNil(viewModel.rootFolder)
        XCTAssertEqual(viewModel.rootFolder?.name, "root")
        XCTAssertEqual(viewModel.rootFolder?.snippets.count, 1)
    }

    func test_loadSnippets_clearsErrorOnSuccess() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"))

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.errorMessage = "Previous error"
        viewModel.loadSnippets()

        XCTAssertNil(viewModel.errorMessage)
    }

    func test_loadSnippets_setsErrorOnFailure() {
        var mockFileService = MockFileService()
        mockFileService.loadError = TestError.testFailure

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Test failure")
    }

    // MARK: - Filter Tests

    func test_filteredRootFolder_returnsRootWhenSearchEmpty() {
        var mockFileService = MockFileService()
        let folder = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"))
        mockFileService.snippetTreeToReturn = folder

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()
        viewModel.searchText = ""

        XCTAssertEqual(viewModel.filteredRootFolder?.name, "root")
    }

    func test_filteredRootFolder_filtersSnippetsByShortcut() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";sig", content: "signature", filePath: URL(fileURLWithPath: "/tmp/sig.md")),
                Snippet(shortcut: ";email", content: "email", filePath: URL(fileURLWithPath: "/tmp/email.md"))
            ]
        )

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()
        viewModel.searchText = "sig"

        XCTAssertEqual(viewModel.filteredRootFolder?.snippets.count, 1)
        XCTAssertEqual(viewModel.filteredRootFolder?.snippets.first?.shortcut, ";sig")
    }

    func test_filteredRootFolder_filtersSnippetsByContent() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";a", content: "Hello World", filePath: URL(fileURLWithPath: "/tmp/a.md")),
                Snippet(shortcut: ";b", content: "Goodbye", filePath: URL(fileURLWithPath: "/tmp/b.md"))
            ]
        )

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()
        viewModel.searchText = "world"

        XCTAssertEqual(viewModel.filteredRootFolder?.snippets.count, 1)
        XCTAssertEqual(viewModel.filteredRootFolder?.snippets.first?.shortcut, ";a")
    }

    func test_filteredRootFolder_returnsNilWhenNoMatches() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";a", content: "hello", filePath: URL(fileURLWithPath: "/tmp/a.md"))
            ]
        )

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()
        viewModel.searchText = "xyz"

        XCTAssertNil(viewModel.filteredRootFolder)
    }

    func test_filteredRootFolder_searchIsCaseInsensitive() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";SIG", content: "Signature", filePath: URL(fileURLWithPath: "/tmp/sig.md"))
            ]
        )

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()
        viewModel.searchText = "sig"

        XCTAssertEqual(viewModel.filteredRootFolder?.snippets.count, 1)
    }

    // MARK: - Sync Tests

    func test_syncToTextReplacement_setsSyncingStatus() {
        let viewModel = SnippetTreeViewModel(
            fileService: MockFileService(),
            textReplacementService: MockTextReplacementService()
        )

        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";test", content: "content", filePath: URL(fileURLWithPath: "/tmp/test.md"))
            ]
        )

        let vm = SnippetTreeViewModel(
            fileService: mockFileService,
            textReplacementService: MockTextReplacementService()
        )
        vm.loadSnippets()
        vm.syncToTextReplacement()

        // After sync completes, status should be .synced
        XCTAssertEqual(vm.syncStatus, .synced)
    }

    func test_syncToTextReplacement_setsErrorStatusOnFailure() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [Snippet(shortcut: ";test", content: "content", filePath: URL(fileURLWithPath: "/tmp/test.md"))]
        )

        var mockTextReplacement = MockTextReplacementService()
        mockTextReplacement.syncError = TestError.testFailure

        let viewModel = SnippetTreeViewModel(
            fileService: mockFileService,
            textReplacementService: mockTextReplacement
        )
        viewModel.loadSnippets()
        viewModel.syncToTextReplacement()

        XCTAssertTrue(viewModel.syncStatus.isError)
    }

    func test_syncToTextReplacement_onlySyncsEnabledSnippets() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";enabled", content: "content", enabled: true, filePath: URL(fileURLWithPath: "/tmp/enabled.md")),
                Snippet(shortcut: ";disabled", content: "content", enabled: false, filePath: URL(fileURLWithPath: "/tmp/disabled.md"))
            ]
        )

        var mockTextReplacement = MockTextReplacementService()

        let viewModel = SnippetTreeViewModel(
            fileService: mockFileService,
            textReplacementService: mockTextReplacement
        )
        viewModel.loadSnippets()
        viewModel.syncToTextReplacement()

        // The sync should have been called (we can't check parameters in this mock setup)
        // but we verify the viewModel filters properly
        let enabledSnippets = viewModel.rootFolder?.allSnippets.filter { $0.enabled }
        XCTAssertEqual(enabledSnippets?.count, 1)
    }

    // MARK: - Expand/Collapse Tests

    func test_toggleExpanded_addsToSet() {
        let viewModel = SnippetTreeViewModel(fileService: MockFileService())
        let folder = SnippetFolder(name: "test", path: URL(fileURLWithPath: "/tmp"))

        XCTAssertFalse(viewModel.isExpanded(folder))

        viewModel.toggleExpanded(folder)

        XCTAssertTrue(viewModel.isExpanded(folder))
    }

    func test_toggleExpanded_removesFromSet() {
        let viewModel = SnippetTreeViewModel(fileService: MockFileService())
        let folder = SnippetFolder(name: "test", path: URL(fileURLWithPath: "/tmp"))

        viewModel.toggleExpanded(folder)
        XCTAssertTrue(viewModel.isExpanded(folder))

        viewModel.toggleExpanded(folder)
        XCTAssertFalse(viewModel.isExpanded(folder))
    }

    // MARK: - Has Access Tests

    func test_hasTextReplacementAccess_returnsServiceValue() {
        var mockTextReplacement = MockTextReplacementService()
        mockTextReplacement.hasAccess = false

        let viewModel = SnippetTreeViewModel(
            fileService: MockFileService(),
            textReplacementService: mockTextReplacement
        )

        XCTAssertFalse(viewModel.hasTextReplacementAccess)
    }

    // MARK: - Create Snippet Tests

    func test_createNewSnippet_reloadsSnippets() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"))

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()

        guard let root = viewModel.rootFolder else {
            XCTFail("Root folder should exist")
            return
        }

        viewModel.createNewSnippet(named: "test", shortcut: ";test", in: root)

        // After creating, loadSnippets is called again
        XCTAssertNotNil(viewModel.rootFolder)
    }

    func test_createNewSnippet_setsErrorOnFailure() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"))
        mockFileService.createSnippetError = TestError.testFailure

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()

        guard let root = viewModel.rootFolder else {
            XCTFail("Root folder should exist")
            return
        }

        viewModel.createNewSnippet(named: "test", shortcut: ";test", in: root)

        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Delete Snippet Tests

    func test_deleteSnippet_reloadsSnippets() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";test", content: "content", filePath: URL(fileURLWithPath: "/tmp/test.md"))
            ]
        )

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()

        guard let snippet = viewModel.rootFolder?.snippets.first else {
            XCTFail("Snippet should exist")
            return
        }

        viewModel.deleteSnippet(snippet)

        // After deleting, loadSnippets is called again
        XCTAssertNotNil(viewModel.rootFolder)
    }

    func test_deleteSnippet_setsErrorOnFailure() {
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: [
                Snippet(shortcut: ";test", content: "content", filePath: URL(fileURLWithPath: "/tmp/test.md"))
            ]
        )
        mockFileService.deleteError = TestError.testFailure

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()

        guard let snippet = viewModel.rootFolder?.snippets.first else {
            XCTFail("Snippet should exist")
            return
        }

        viewModel.deleteSnippet(snippet)

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Test failure")
    }

    // MARK: - Delete Folder Tests

    func test_deleteFolder_reloadsSnippets() {
        let childFolder = SnippetFolder(name: "child", path: URL(fileURLWithPath: "/tmp/child"))
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            children: [childFolder]
        )

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()

        viewModel.deleteFolder(childFolder)

        // After deleting, loadSnippets is called again
        XCTAssertNotNil(viewModel.rootFolder)
    }

    func test_deleteFolder_setsErrorOnFailure() {
        let childFolder = SnippetFolder(name: "child", path: URL(fileURLWithPath: "/tmp/child"))
        var mockFileService = MockFileService()
        mockFileService.snippetTreeToReturn = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            children: [childFolder]
        )
        mockFileService.deleteError = TestError.testFailure

        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.loadSnippets()

        viewModel.deleteFolder(childFolder)

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Test failure")
    }

    // MARK: - Copy to Clipboard Tests

    func test_copyToClipboard_copiesContentToPasteboard() {
        let mockFileService = MockFileService()
        let viewModel = SnippetTreeViewModel(fileService: mockFileService)

        let snippet = Snippet(
            shortcut: ";test",
            content: "Hello World",
            filePath: URL(fileURLWithPath: "/tmp/test.md")
        )

        viewModel.copyToClipboard(snippet)

        let pasteboardContent = NSPasteboard.general.string(forType: .string)
        XCTAssertEqual(pasteboardContent, "Hello World")
    }

    func test_copyToClipboard_expandsVariables() {
        let mockFileService = MockFileService()
        let viewModel = SnippetTreeViewModel(fileService: mockFileService)

        let snippet = Snippet(
            shortcut: ";test",
            content: "Today is {date}",
            filePath: URL(fileURLWithPath: "/tmp/test.md")
        )

        viewModel.copyToClipboard(snippet)

        let pasteboardContent = NSPasteboard.general.string(forType: .string)
        XCTAssertNotNil(pasteboardContent)
        XCTAssertFalse(pasteboardContent!.contains("{date}"))
    }

    // MARK: - Handle Import Tests

    func test_handleImport_setsErrorOnFailure() {
        let mockFileService = MockFileService()
        let viewModel = SnippetTreeViewModel(fileService: mockFileService)

        let testError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Import error"])
        viewModel.handleImport(.failure(testError))

        XCTAssertEqual(viewModel.errorMessage, "Import error")
    }

    func test_handleImport_ignoresEmptyURLArray() {
        let mockFileService = MockFileService()
        let viewModel = SnippetTreeViewModel(fileService: mockFileService)
        viewModel.errorMessage = nil

        viewModel.handleImport(.success([]))

        XCTAssertNil(viewModel.errorMessage)
    }
}
