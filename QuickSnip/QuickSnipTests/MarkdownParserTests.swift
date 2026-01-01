import XCTest
@testable import QuickSnip

final class MarkdownParserTests: XCTestCase {

    // MARK: - Parsing Tests

    func test_parse_extractsShortcut() {
        let input = """
            ---
            shortcut: ;sig
            ---
            Content here
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.shortcut, ";sig")
    }

    func test_parse_extractsContent() {
        let input = """
            ---
            shortcut: ;test
            ---
            Hello, World!
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.content, "Hello, World!")
    }

    func test_parse_extractsMultilineContent() {
        let input = """
            ---
            shortcut: ;multi
            ---
            Line 1
            Line 2
            Line 3
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.content, "Line 1\nLine 2\nLine 3")
    }

    func test_parse_extractsCategory() {
        let input = """
            ---
            shortcut: ;work
            category: work
            ---
            Content
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.category, "work")
    }

    func test_parse_defaultsEnabledToTrue() {
        let input = """
            ---
            shortcut: ;test
            ---
            Content
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertTrue(result?.enabled ?? false)
    }

    func test_parse_respectsEnabledFalse() {
        let input = """
            ---
            shortcut: ;disabled
            enabled: false
            ---
            Content
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertFalse(result?.enabled ?? true)
    }

    func test_parse_returnsNilWithoutFrontmatter() {
        let input = "Just plain text without frontmatter"

        let result = MarkdownParser.parse(input)

        XCTAssertNil(result)
    }

    func test_parse_returnsNilWithoutClosingDelimiter() {
        let input = """
            ---
            shortcut: ;test
            Content without closing delimiter
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNil(result)
    }

    func test_parse_returnsNilWithoutShortcut() {
        let input = """
            ---
            category: work
            ---
            Content without shortcut
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNil(result)
    }

    func test_parse_handlesEmptyCategory() {
        let input = """
            ---
            shortcut: ;test
            category:
            ---
            Content
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertNil(result?.category)
    }

    func test_parse_handlesCaseInsensitiveKeys() {
        let input = """
            ---
            SHORTCUT: ;upper
            CATEGORY: WORK
            ENABLED: true
            ---
            Content
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.shortcut, ";upper")
        XCTAssertEqual(result?.category, "WORK")
    }

    func test_parse_handlesWhitespaceAroundValues() {
        let input = """
            ---
            shortcut:   ;spaced
            category:   personal
            ---
            Content
            """

        let result = MarkdownParser.parse(input)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.shortcut, ";spaced")
        XCTAssertEqual(result?.category, "personal")
    }

    // MARK: - Generation Tests

    func test_generate_producesValidFrontmatter() {
        let output = MarkdownParser.generateMarkdown(
            shortcut: ";test",
            content: "Hello"
        )

        XCTAssertTrue(output.hasPrefix("---\n"))
        XCTAssertTrue(output.contains("shortcut: ;test"))
        XCTAssertTrue(output.contains("---\nHello"))
    }

    func test_generate_includesCategory() {
        let output = MarkdownParser.generateMarkdown(
            shortcut: ";test",
            content: "Hello",
            category: "work"
        )

        XCTAssertTrue(output.contains("category: work"))
    }

    func test_generate_omitsCategoryWhenNil() {
        let output = MarkdownParser.generateMarkdown(
            shortcut: ";test",
            content: "Hello",
            category: nil
        )

        XCTAssertFalse(output.contains("category:"))
    }

    func test_generate_includesEnabledFalse() {
        let output = MarkdownParser.generateMarkdown(
            shortcut: ";test",
            content: "Hello",
            enabled: false
        )

        XCTAssertTrue(output.contains("enabled: false"))
    }

    func test_generate_omitsEnabledWhenTrue() {
        let output = MarkdownParser.generateMarkdown(
            shortcut: ";test",
            content: "Hello",
            enabled: true
        )

        XCTAssertFalse(output.contains("enabled:"))
    }

    // MARK: - Round-trip Tests

    func test_roundTrip_preservesAllFields() {
        let original = MarkdownParser.generateMarkdown(
            shortcut: ";roundtrip",
            content: "Test content\nWith multiple lines",
            category: "testing",
            enabled: false
        )

        let parsed = MarkdownParser.parse(original)

        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.shortcut, ";roundtrip")
        XCTAssertEqual(parsed?.content, "Test content\nWith multiple lines")
        XCTAssertEqual(parsed?.category, "testing")
        XCTAssertFalse(parsed?.enabled ?? true)
    }
}
