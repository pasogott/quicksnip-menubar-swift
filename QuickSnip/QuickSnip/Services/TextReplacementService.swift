import Foundation
import AppKit

struct TextReplacement: Equatable {
    let shortcut: String
    let phrase: String
}

struct TextReplacementService: TextReplacementServiceProtocol {
    static let databaseURL: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home
            .appendingPathComponent("Library/KeyboardServices/TextReplacements.db")
    }()

    var hasAccess: Bool {
        guard let fileHandle = try? FileHandle(forWritingTo: Self.databaseURL) else {
            return false
        }
        try? fileHandle.close()
        return true
    }

    func getCurrentReplacements() throws -> [TextReplacement] {
        let db = SQLiteDatabase(url: Self.databaseURL)
        try db.open()
        defer { db.close() }

        let rows = try db.query("""
            SELECT ZSHORTCUT, ZPHRASE FROM ZTEXTREPLACEMENTENTRY
            WHERE ZSHORTCUT IS NOT NULL AND ZPHRASE IS NOT NULL
        """)

        return rows.compactMap { row in
            guard let shortcut = row["ZSHORTCUT"] as? String,
                  let phrase = row["ZPHRASE"] as? String else {
                return nil
            }
            return TextReplacement(shortcut: shortcut, phrase: phrase)
        }
    }

    func syncSnippets(_ snippets: [Snippet]) throws -> SyncResult {
        let db = SQLiteDatabase(url: Self.databaseURL)
        try db.open()
        defer { db.close() }

        let existing = try getCurrentReplacements()
        let existingShortcuts = Set(existing.map { $0.shortcut })

        var inserted = 0
        var updated = 0

        for snippet in snippets where snippet.enabled {
            let phrase = snippet.content
            let shortcut = snippet.shortcut

            if existingShortcuts.contains(shortcut) {
                try db.execute("""
                    UPDATE ZTEXTREPLACEMENTENTRY
                    SET ZPHRASE = ?, ZTIMESTAMP = ?
                    WHERE ZSHORTCUT = ?
                """, parameters: [phrase, currentTimestamp(), shortcut])
                updated += 1
            } else {
                let maxZ: Int64 = try db.queryScalar("""
                    SELECT MAX(Z_PK) FROM ZTEXTREPLACEMENTENTRY
                """) ?? 0

                try db.execute("""
                    INSERT INTO ZTEXTREPLACEMENTENTRY
                    (Z_PK, Z_ENT, Z_OPT, ZSHORTCUT, ZPHRASE, ZTIMESTAMP, ZWASDELETED)
                    VALUES (?, 1, 1, ?, ?, ?, 0)
                """, parameters: [maxZ + 1, shortcut, phrase, currentTimestamp()])
                inserted += 1
            }
        }

        touchDatabase()

        return SyncResult(inserted: inserted, updated: updated)
    }

    func openFullDiskAccessSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)
    }

    private func currentTimestamp() -> Double {
        Date().timeIntervalSinceReferenceDate
    }

    private func touchDatabase() {
        try? FileManager.default.setAttributes(
            [.modificationDate: Date()],
            ofItemAtPath: Self.databaseURL.path
        )
    }
}

struct SyncResult {
    let inserted: Int
    let updated: Int

    var total: Int { inserted + updated }

    var description: String {
        if total == 0 {
            return "No changes"
        }
        var parts: [String] = []
        if inserted > 0 {
            parts.append("\(inserted) added")
        }
        if updated > 0 {
            parts.append("\(updated) updated")
        }
        return parts.joined(separator: ", ")
    }
}
