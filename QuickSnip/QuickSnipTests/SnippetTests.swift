import XCTest
@testable import QuickSnip

final class SnippetTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_setsAllProperties() {
        let filePath = URL(fileURLWithPath: "/tmp/test.md")
        let date = Date()

        let snippet = Snippet(
            shortcut: ";test",
            content: "Hello",
            category: "work",
            enabled: false,
            filePath: filePath,
            lastModified: date
        )

        XCTAssertEqual(snippet.shortcut, ";test")
        XCTAssertEqual(snippet.content, "Hello")
        XCTAssertEqual(snippet.category, "work")
        XCTAssertFalse(snippet.enabled)
        XCTAssertEqual(snippet.filePath, filePath)
        XCTAssertEqual(snippet.lastModified, date)
    }

    func test_init_defaultsEnabledToTrue() {
        let snippet = Snippet(
            shortcut: ";test",
            content: "Hello",
            filePath: URL(fileURLWithPath: "/tmp/test.md")
        )

        XCTAssertTrue(snippet.enabled)
    }

    func test_init_defaultsCategoryToNil() {
        let snippet = Snippet(
            shortcut: ";test",
            content: "Hello",
            filePath: URL(fileURLWithPath: "/tmp/test.md")
        )

        XCTAssertNil(snippet.category)
    }

    func test_init_generatesUUID() {
        let snippet = Snippet(
            shortcut: ";test",
            content: "Hello",
            filePath: URL(fileURLWithPath: "/tmp/test.md")
        )

        XCTAssertNotEqual(snippet.id, UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }

    // MARK: - fileName Tests

    func test_fileName_extractsNameWithoutExtension() {
        let snippet = Snippet(
            shortcut: ";test",
            content: "Hello",
            filePath: URL(fileURLWithPath: "/tmp/my-snippet.md")
        )

        XCTAssertEqual(snippet.fileName, "my-snippet")
    }

    func test_fileName_handlesNestedPath() {
        let snippet = Snippet(
            shortcut: ";test",
            content: "Hello",
            filePath: URL(fileURLWithPath: "/home/user/.snippets/work/email.md")
        )

        XCTAssertEqual(snippet.fileName, "email")
    }

    func test_fileName_handlesSpaces() {
        let snippet = Snippet(
            shortcut: ";test",
            content: "Hello",
            filePath: URL(fileURLWithPath: "/tmp/my snippet.md")
        )

        XCTAssertEqual(snippet.fileName, "my snippet")
    }

    // MARK: - Equality Tests

    func test_equality_samePropertiesAreEqual() {
        let id = UUID()
        let date = Date()
        let snippet1 = Snippet(
            id: id,
            shortcut: ";test",
            content: "Content",
            category: "work",
            enabled: true,
            filePath: URL(fileURLWithPath: "/tmp/test.md"),
            lastModified: date
        )
        let snippet2 = Snippet(
            id: id,
            shortcut: ";test",
            content: "Content",
            category: "work",
            enabled: true,
            filePath: URL(fileURLWithPath: "/tmp/test.md"),
            lastModified: date
        )

        XCTAssertEqual(snippet1, snippet2)
    }

    func test_equality_differentIdAreNotEqual() {
        let snippet1 = Snippet(
            shortcut: ";test",
            content: "Hello",
            filePath: URL(fileURLWithPath: "/tmp/test.md")
        )
        let snippet2 = Snippet(
            shortcut: ";test",
            content: "Hello",
            filePath: URL(fileURLWithPath: "/tmp/test.md")
        )

        XCTAssertNotEqual(snippet1, snippet2)
    }
}
