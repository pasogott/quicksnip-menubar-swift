import Foundation

// MARK: - File Service Protocol

protocol SnippetFileServiceProtocol: Sendable {
    var snippetsDirectory: URL { get }

    func loadSnippetTree() throws -> SnippetFolder
    func createSnippet(named name: String, shortcut: String, in folder: SnippetFolder) throws -> Snippet
    func createFolder(named name: String, in parent: SnippetFolder) throws -> SnippetFolder
    func deleteSnippet(_ snippet: Snippet) throws
    func deleteFolder(_ folder: SnippetFolder) throws
}

// MARK: - Text Replacement Protocol

protocol TextReplacementServiceProtocol: Sendable {
    var hasAccess: Bool { get }

    func syncSnippets(_ snippets: [Snippet]) throws -> SyncResult
    func openFullDiskAccessSettings()
}
