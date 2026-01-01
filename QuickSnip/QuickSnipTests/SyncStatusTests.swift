import XCTest
@testable import QuickSnip

final class SyncStatusTests: XCTestCase {

    // MARK: - Symbol Name Tests

    func test_idle_hasCorrectSymbol() {
        XCTAssertEqual(SyncStatus.idle.symbolName, "arrow.triangle.2.circlepath")
    }

    func test_syncing_hasCorrectSymbol() {
        XCTAssertEqual(SyncStatus.syncing.symbolName, "arrow.triangle.2.circlepath.circle")
    }

    func test_synced_hasCorrectSymbol() {
        XCTAssertEqual(SyncStatus.synced.symbolName, "checkmark.circle.fill")
    }

    func test_error_hasCorrectSymbol() {
        XCTAssertEqual(SyncStatus.error("test").symbolName, "exclamationmark.triangle.fill")
    }

    // MARK: - Description Tests

    func test_idle_hasCorrectDescription() {
        XCTAssertEqual(SyncStatus.idle.description, "Ready to sync")
    }

    func test_syncing_hasCorrectDescription() {
        XCTAssertEqual(SyncStatus.syncing.description, "Syncing...")
    }

    func test_synced_hasCorrectDescription() {
        XCTAssertEqual(SyncStatus.synced.description, "Synced")
    }

    func test_error_includesMessageInDescription() {
        let status = SyncStatus.error("Connection failed")
        XCTAssertEqual(status.description, "Error: Connection failed")
    }

    // MARK: - isError Tests

    func test_idle_isNotError() {
        XCTAssertFalse(SyncStatus.idle.isError)
    }

    func test_syncing_isNotError() {
        XCTAssertFalse(SyncStatus.syncing.isError)
    }

    func test_synced_isNotError() {
        XCTAssertFalse(SyncStatus.synced.isError)
    }

    func test_error_isError() {
        XCTAssertTrue(SyncStatus.error("test").isError)
    }

    // MARK: - Equality Tests

    func test_equality_sameStatusesAreEqual() {
        XCTAssertEqual(SyncStatus.idle, SyncStatus.idle)
        XCTAssertEqual(SyncStatus.syncing, SyncStatus.syncing)
        XCTAssertEqual(SyncStatus.synced, SyncStatus.synced)
    }

    func test_equality_differentStatusesAreNotEqual() {
        XCTAssertNotEqual(SyncStatus.idle, SyncStatus.syncing)
        XCTAssertNotEqual(SyncStatus.syncing, SyncStatus.synced)
    }

    func test_equality_errorsWithSameMessageAreEqual() {
        XCTAssertEqual(
            SyncStatus.error("same message"),
            SyncStatus.error("same message")
        )
    }

    func test_equality_errorsWithDifferentMessagesAreNotEqual() {
        XCTAssertNotEqual(
            SyncStatus.error("message 1"),
            SyncStatus.error("message 2")
        )
    }
}
