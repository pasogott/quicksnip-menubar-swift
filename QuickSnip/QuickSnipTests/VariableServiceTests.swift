import XCTest
@testable import QuickSnip

final class VariableServiceTests: XCTestCase {

    // MARK: - Date Variable Tests

    func test_expand_replacesDateVariable() {
        let input = "Today is {date}"

        let result = VariableService.expand(input)

        XCTAssertFalse(result.contains("{date}"))
        // Date format depends on locale, so just check it's been replaced
        XCTAssertTrue(result.hasPrefix("Today is "))
        XCTAssertGreaterThan(result.count, "Today is ".count)
    }

    func test_expand_replacesMultipleDateVariables() {
        let input = "Start: {date}, End: {date}"

        let result = VariableService.expand(input)

        XCTAssertFalse(result.contains("{date}"))
        XCTAssertTrue(result.contains("Start:"))
        XCTAssertTrue(result.contains("End:"))
    }

    // MARK: - Time Variable Tests

    func test_expand_replacesTimeVariable() {
        let input = "Current time: {time}"

        let result = VariableService.expand(input)

        XCTAssertFalse(result.contains("{time}"))
        XCTAssertTrue(result.hasPrefix("Current time: "))
        XCTAssertGreaterThan(result.count, "Current time: ".count)
    }

    // MARK: - Unknown Variable Tests

    func test_expand_preservesUnknownVariables() {
        let input = "Hello {unknown}"

        let result = VariableService.expand(input)

        XCTAssertEqual(result, "Hello {unknown}")
    }

    func test_expand_preservesMalformedVariables() {
        let input = "Hello {date"

        let result = VariableService.expand(input)

        XCTAssertEqual(result, "Hello {date")
    }

    // MARK: - Multiple Variable Tests

    func test_expand_replacesMultipleDifferentVariables() {
        let input = "Date: {date}, Time: {time}"

        let result = VariableService.expand(input)

        XCTAssertFalse(result.contains("{date}"))
        XCTAssertFalse(result.contains("{time}"))
    }

    // MARK: - No Variable Tests

    func test_expand_returnsUnchangedForNoVariables() {
        let input = "Plain text without variables"

        let result = VariableService.expand(input)

        XCTAssertEqual(result, input)
    }

    func test_expand_preservesWhitespace() {
        let input = "  spaces  and\ttabs\nand newlines  "

        let result = VariableService.expand(input)

        XCTAssertEqual(result, input)
    }

    func test_expand_handlesEmptyString() {
        let input = ""

        let result = VariableService.expand(input)

        XCTAssertEqual(result, "")
    }
}
