import Foundation
import SQLite3

final class SQLiteDatabase {
    private var db: OpaquePointer?
    private let path: String

    var isOpen: Bool { db != nil }

    init(path: String) {
        self.path = path
    }

    convenience init(url: URL) {
        self.init(path: url.path)
    }

    deinit {
        close()
    }

    func open() throws {
        guard db == nil else { return }

        let result = sqlite3_open(path, &db)
        if result != SQLITE_OK {
            let message = errorMessage
            db = nil
            throw SQLiteError.openFailed(message)
        }
    }

    func close() {
        guard let database = db else { return }
        sqlite3_close(database)
        db = nil
    }

    func execute(_ sql: String) throws {
        guard let database = db else {
            throw SQLiteError.notOpen
        }

        var errorPointer: UnsafeMutablePointer<CChar>?
        let result = sqlite3_exec(database, sql, nil, nil, &errorPointer)

        if result != SQLITE_OK {
            let message = errorPointer.map { String(cString: $0) } ?? "Unknown error"
            sqlite3_free(errorPointer)
            throw SQLiteError.executeFailed(message)
        }
    }

    func query(_ sql: String) throws -> [[String: Any]] {
        guard let database = db else {
            throw SQLiteError.notOpen
        }

        var statement: OpaquePointer?
        let prepareResult = sqlite3_prepare_v2(database, sql, -1, &statement, nil)

        guard prepareResult == SQLITE_OK, let stmt = statement else {
            throw SQLiteError.prepareFailed(errorMessage)
        }

        defer { sqlite3_finalize(stmt) }

        var rows: [[String: Any]] = []
        let columnCount = sqlite3_column_count(stmt)

        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [String: Any] = [:]

            for i in 0..<columnCount {
                let columnName = String(cString: sqlite3_column_name(stmt, i))
                let columnType = sqlite3_column_type(stmt, i)

                switch columnType {
                case SQLITE_INTEGER:
                    row[columnName] = sqlite3_column_int64(stmt, i)
                case SQLITE_FLOAT:
                    row[columnName] = sqlite3_column_double(stmt, i)
                case SQLITE_TEXT:
                    if let text = sqlite3_column_text(stmt, i) {
                        row[columnName] = String(cString: text)
                    }
                case SQLITE_BLOB:
                    if let blob = sqlite3_column_blob(stmt, i) {
                        let size = sqlite3_column_bytes(stmt, i)
                        row[columnName] = Data(bytes: blob, count: Int(size))
                    }
                case SQLITE_NULL:
                    row[columnName] = NSNull()
                default:
                    break
                }
            }

            rows.append(row)
        }

        return rows
    }

    func queryScalar<T>(_ sql: String) throws -> T? {
        let rows = try query(sql)
        guard let firstRow = rows.first, let firstValue = firstRow.values.first else {
            return nil
        }
        return firstValue as? T
    }

    private var errorMessage: String {
        if let error = sqlite3_errmsg(db) {
            return String(cString: error)
        }
        return "Unknown error"
    }
}

enum SQLiteError: LocalizedError {
    case openFailed(String)
    case notOpen
    case prepareFailed(String)
    case executeFailed(String)

    var errorDescription: String? {
        switch self {
        case .openFailed(let message):
            return "Failed to open database: \(message)"
        case .notOpen:
            return "Database is not open"
        case .prepareFailed(let message):
            return "Failed to prepare statement: \(message)"
        case .executeFailed(let message):
            return "Failed to execute statement: \(message)"
        }
    }
}
