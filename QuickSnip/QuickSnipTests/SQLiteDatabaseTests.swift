import XCTest
@testable import QuickSnip

final class SQLiteDatabaseTests: XCTestCase {

    var db: SQLiteDatabase!
    var tempPath: String!

    override func setUp() {
        super.setUp()
        tempPath = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".db").path
        db = SQLiteDatabase(path: tempPath)
    }

    override func tearDown() {
        db.close()
        try? FileManager.default.removeItem(atPath: tempPath)
        super.tearDown()
    }

    // MARK: - Open/Close Tests

    func test_open_setsIsOpenToTrue() throws {
        XCTAssertFalse(db.isOpen)

        try db.open()

        XCTAssertTrue(db.isOpen)
    }

    func test_close_setsIsOpenToFalse() throws {
        try db.open()
        XCTAssertTrue(db.isOpen)

        db.close()

        XCTAssertFalse(db.isOpen)
    }

    func test_open_canBeCalledMultipleTimes() throws {
        try db.open()
        try db.open() // Should not throw

        XCTAssertTrue(db.isOpen)
    }

    func test_close_canBeCalledMultipleTimes() throws {
        try db.open()
        db.close()
        db.close() // Should not crash

        XCTAssertFalse(db.isOpen)
    }

    // MARK: - Execute Tests

    func test_execute_createsTable() throws {
        try db.open()

        try db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")

        let rows = try db.query("SELECT name FROM sqlite_master WHERE type='table' AND name='test'")
        XCTAssertEqual(rows.count, 1)
    }

    func test_execute_insertsRow() throws {
        try db.open()
        try db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")

        try db.execute("INSERT INTO test (id, name) VALUES (?, ?)", parameters: [1, "Alice"])

        let rows = try db.query("SELECT * FROM test")
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0]["name"] as? String, "Alice")
    }

    func test_execute_throwsWhenNotOpen() {
        XCTAssertThrowsError(try db.execute("SELECT 1")) { error in
            XCTAssertEqual(error as? SQLiteError, SQLiteError.notOpen)
        }
    }

    // MARK: - Parameter Binding Tests

    func test_execute_bindsStringParameter() throws {
        try db.open()
        try db.execute("CREATE TABLE test (name TEXT)")

        try db.execute("INSERT INTO test (name) VALUES (?)", parameters: ["Bob"])

        let rows = try db.query("SELECT * FROM test")
        XCTAssertEqual(rows[0]["name"] as? String, "Bob")
    }

    func test_execute_bindsIntParameter() throws {
        try db.open()
        try db.execute("CREATE TABLE test (value INTEGER)")

        try db.execute("INSERT INTO test (value) VALUES (?)", parameters: [42])

        let rows = try db.query("SELECT * FROM test")
        XCTAssertEqual(rows[0]["value"] as? Int64, 42)
    }

    func test_execute_bindsDoubleParameter() throws {
        try db.open()
        try db.execute("CREATE TABLE test (value REAL)")

        try db.execute("INSERT INTO test (value) VALUES (?)", parameters: [3.14])

        let rows = try db.query("SELECT * FROM test")
        let value = rows[0]["value"] as? Double ?? 0.0
        XCTAssertEqual(value, 3.14, accuracy: 0.001)
    }

    func test_execute_bindsNullParameter() throws {
        try db.open()
        try db.execute("CREATE TABLE test (value TEXT)")

        try db.execute("INSERT INTO test (value) VALUES (?)", parameters: [nil] as [Any?])

        let rows = try db.query("SELECT * FROM test")
        XCTAssertTrue(rows[0]["value"] is NSNull)
    }

    func test_execute_bindsMultipleParameters() throws {
        try db.open()
        try db.execute("CREATE TABLE test (id INTEGER, name TEXT, score REAL)")

        try db.execute(
            "INSERT INTO test (id, name, score) VALUES (?, ?, ?)",
            parameters: [1, "Charlie", 95.5]
        )

        let rows = try db.query("SELECT * FROM test")
        XCTAssertEqual(rows[0]["id"] as? Int64, 1)
        XCTAssertEqual(rows[0]["name"] as? String, "Charlie")
        XCTAssertEqual(rows[0]["score"] as? Double, 95.5)
    }

    // MARK: - Query Tests

    func test_query_returnsEmptyArrayForEmptyTable() throws {
        try db.open()
        try db.execute("CREATE TABLE test (id INTEGER)")

        let rows = try db.query("SELECT * FROM test")

        XCTAssertTrue(rows.isEmpty)
    }

    func test_query_returnsMultipleRows() throws {
        try db.open()
        try db.execute("CREATE TABLE test (id INTEGER, name TEXT)")
        try db.execute("INSERT INTO test VALUES (1, 'Alice')")
        try db.execute("INSERT INTO test VALUES (2, 'Bob')")
        try db.execute("INSERT INTO test VALUES (3, 'Charlie')")

        let rows = try db.query("SELECT * FROM test ORDER BY id")

        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(rows[0]["name"] as? String, "Alice")
        XCTAssertEqual(rows[1]["name"] as? String, "Bob")
        XCTAssertEqual(rows[2]["name"] as? String, "Charlie")
    }

    func test_query_throwsWhenNotOpen() {
        XCTAssertThrowsError(try db.query("SELECT 1")) { error in
            XCTAssertEqual(error as? SQLiteError, SQLiteError.notOpen)
        }
    }

    // MARK: - QueryScalar Tests

    func test_queryScalar_returnsValue() throws {
        try db.open()
        try db.execute("CREATE TABLE test (value INTEGER)")
        try db.execute("INSERT INTO test VALUES (42)")

        let result: Int64? = try db.queryScalar("SELECT value FROM test")

        XCTAssertEqual(result, 42)
    }

    func test_queryScalar_returnsNilForEmptyResult() throws {
        try db.open()
        try db.execute("CREATE TABLE test (value INTEGER)")

        let result: Int64? = try db.queryScalar("SELECT value FROM test")

        XCTAssertNil(result)
    }

    func test_queryScalar_returnsMaxValue() throws {
        try db.open()
        try db.execute("CREATE TABLE test (value INTEGER)")
        try db.execute("INSERT INTO test VALUES (10)")
        try db.execute("INSERT INTO test VALUES (20)")
        try db.execute("INSERT INTO test VALUES (15)")

        let result: Int64? = try db.queryScalar("SELECT MAX(value) FROM test")

        XCTAssertEqual(result, 20)
    }
}
