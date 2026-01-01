import Foundation

// MARK: - File Service Protocol

protocol SnippetFileServiceProtocol: Sendable {
    var snippetsDirectory: URL { get }

    func loadSnippetTree() throws -> SnippetFolder
    func createSnippet(named name: String, shortcut: String, in folder: SnippetFolder) throws -> Snippet
    func createFolder(named name: String, in parent: SnippetFolder) throws -> SnippetFolder
    func deleteSnippet(_ snippet: Snippet) throws
    func deleteFolder(_ folder: SnippetFolder) throws
    func snippetFromFile(_ fileURL: URL) -> Snippet?
}

// MARK: - Text Replacement Protocol

protocol TextReplacementServiceProtocol: Sendable {
    var hasAccess: Bool { get }

    func syncSnippets(_ snippets: [Snippet]) throws -> SyncResult
    func getCurrentReplacements() throws -> [TextReplacement]
    func openFullDiskAccessSettings()
}

// MARK: - Notification Protocol

@MainActor
protocol NotificationServiceProtocol {
    func requestAuthorization()
    func showSuccess(title: String, message: String)
    func showError(title: String, message: String)
}

// MARK: - File Watcher Protocol

@MainActor
protocol FileWatcherServiceProtocol: AnyObject {
    var isRunning: Bool { get }

    func start()
    func stop()
}
