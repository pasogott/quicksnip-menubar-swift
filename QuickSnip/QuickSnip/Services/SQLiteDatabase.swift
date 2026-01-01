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

    func execute(_ sql: String, parameters: [Any?] = []) throws {
        guard let database = db else {
            throw SQLiteError.notOpen
        }

        var statement: OpaquePointer?
        let prepareResult = sqlite3_prepare_v2(database, sql, -1, &statement, nil)

        guard prepareResult == SQLITE_OK, let stmt = statement else {
            throw SQLiteError.prepareFailed(errorMessage)
        }

        defer { sqlite3_finalize(stmt) }

        try bindParameters(parameters, to: stmt)

        let stepResult = sqlite3_step(stmt)
        if stepResult != SQLITE_DONE && stepResult != SQLITE_ROW {
            throw SQLiteError.executeFailed(errorMessage)
        }
    }

    private func bindParameters(_ parameters: [Any?], to stmt: OpaquePointer) throws {
        for (index, param) in parameters.enumerated() {
            let sqlIndex = Int32(index + 1)

            switch param {
            case nil:
                sqlite3_bind_null(stmt, sqlIndex)
            case let value as String:
                sqlite3_bind_text(stmt, sqlIndex, value, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            case let value as Int:
                sqlite3_bind_int64(stmt, sqlIndex, Int64(value))
            case let value as Int64:
                sqlite3_bind_int64(stmt, sqlIndex, value)
            case let value as Double:
                sqlite3_bind_double(stmt, sqlIndex, value)
            case let value as Data:
                _ = value.withUnsafeBytes { ptr in
                    sqlite3_bind_blob(stmt, sqlIndex, ptr.baseAddress, Int32(value.count), unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                }
            default:
                throw SQLiteError.bindFailed("Unsupported parameter type at index \(index)")
            }
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

enum SQLiteError: LocalizedError, Equatable {
    case openFailed(String)
    case notOpen
    case prepareFailed(String)
    case executeFailed(String)
    case bindFailed(String)

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
        case .bindFailed(let message):
            return "Failed to bind parameter: \(message)"
        }
    }
}
