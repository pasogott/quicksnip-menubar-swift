import Foundation
import AppKit

// MARK: - Architecture Decision Record
//
// Why we manipulate system databases directly instead of using official Apple APIs:
//
// The core feature of QuickSnip is syncing snippets to iOS via iCloud. This requires
// writing to macOS Text Replacement, which has NO public API.
//
// Alternatives considered:
//
// 1. InputMethodKit - Apple's official text input API
//    - Requires separate Input Method bundle that users must manually enable
//    - Does NOT sync to iOS - completely separate from Text Replacement
//    - Complex implementation (full IMKit architecture)
//
// 2. Event Taps (CGEvent) - Keyboard interception
//    - Requires Input Monitoring permission (more intrusive than FDA)
//    - Does NOT sync to iOS
//    - Must run constantly in background, higher battery impact
//
// 3. NSSpellChecker.learnWord() - Only for spell checking, not text replacement
//
// Current approach (direct database access):
// - Writes to ~/Library/KeyboardServices/TextReplacements.db (for iCloud sync)
// - Updates .GlobalPreferences.plist (for immediate local activation)
// - Restarts keyboardservicesd daemon
//
// This is the same approach used by Keyboard Maestro and other established tools.
// The schema has been stable across macOS versions.
//
// Risks: Undocumented API could change. Mitigation: Monitor macOS betas.
//
// References:
// - https://forum.keyboardmaestro.com/t/native-macos-text-replacement-adding-records/17112
// - https://sqlite.org/wal.html (WAL checkpoint requirement)

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
        let testURL = Self.databaseURL.deletingLastPathComponent()
            .appendingPathComponent(".quicksnip_fda_test")
        do {
            try "test".write(to: testURL, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(at: testURL)
            return true
        } catch {
            return false
        }
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
        var maxPK: Int64 = try db.queryScalar(
            "SELECT MAX(Z_PK) FROM ZTEXTREPLACEMENTENTRY"
        ) ?? 0

        for snippet in snippets where snippet.enabled {
            let phrase = snippet.content
            let shortcut = snippet.shortcut

            if existingShortcuts.contains(shortcut) {
                try db.execute("""
                    UPDATE ZTEXTREPLACEMENTENTRY
                    SET ZPHRASE = ?, ZTIMESTAMP = ?, ZNEEDSSAVETOCLOUD = 1
                    WHERE ZSHORTCUT = ?
                """, parameters: [phrase, currentTimestamp(), shortcut])
                updated += 1
            } else {
                maxPK += 1
                let uniqueName = UUID().uuidString
                try db.execute("""
                    INSERT INTO ZTEXTREPLACEMENTENTRY
                    (Z_PK, Z_ENT, Z_OPT, ZNEEDSSAVETOCLOUD, ZWASDELETED,
                     ZTIMESTAMP, ZPHRASE, ZSHORTCUT, ZUNIQUENAME)
                    VALUES (?, 1, 1, 1, 0, ?, ?, ?, ?)
                """, parameters: [maxPK, currentTimestamp(), phrase, shortcut, uniqueName])
                inserted += 1
            }
        }

        if inserted > 0 {
            try db.execute("""
                UPDATE Z_PRIMARYKEY SET Z_MAX = ? WHERE Z_NAME = 'TextReplacementEntry'
            """, parameters: [maxPK])
        }

        try db.checkpoint()
        touchDatabase()
        updateGlobalPreferences(snippets)
        restartKeyboardService()

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

    private func restartKeyboardService() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        task.arguments = ["keyboardservicesd"]
        try? task.run()
    }

    /// Updates GlobalPreferences.plist for immediate local activation.
    /// The database handles iCloud sync, but macOS reads from plist for immediate use.
    private func updateGlobalPreferences(_ snippets: [Snippet]) {
        let key = "NSUserDictionaryReplacementItems"
        let defaults = UserDefaults.standard
        var globalDomain = defaults.persistentDomain(forName: UserDefaults.globalDomain) ?? [:]
        var replacements = globalDomain[key] as? [[String: Any]] ?? []
        let existingShortcuts = Set(replacements.compactMap { $0["replace"] as? String })

        for snippet in snippets where snippet.enabled {
            if existingShortcuts.contains(snippet.shortcut) {
                // Update existing entry
                if let index = replacements.firstIndex(where: { ($0["replace"] as? String) == snippet.shortcut }) {
                    replacements[index] = [
                        "on": 1,
                        "replace": snippet.shortcut,
                        "with": snippet.content
                    ]
                }
            } else {
                // Add new entry
                replacements.append([
                    "on": 1,
                    "replace": snippet.shortcut,
                    "with": snippet.content
                ])
            }
        }

        globalDomain[key] = replacements
        defaults.setPersistentDomain(globalDomain, forName: UserDefaults.globalDomain)
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
