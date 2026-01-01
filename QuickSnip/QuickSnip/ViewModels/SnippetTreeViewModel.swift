import Foundation
import AppKit
import Observation

@MainActor
@Observable
final class SnippetTreeViewModel: FileWatcherDelegate {
    var rootFolder: SnippetFolder?
    var syncStatus: SyncStatus = .idle
    var searchText: String = ""
    var errorMessage: String?
    var expandedFolderIDs: Set<UUID> = []

    private let fileService = SnippetFileService()
    private let textReplacementService = TextReplacementService()
    private let notificationService = NotificationService.shared
    private var fileWatcher: FileWatcherService?

    var filteredRootFolder: SnippetFolder? {
        guard !searchText.isEmpty else { return rootFolder }
        return filterFolder(rootFolder, searchText: searchText.lowercased())
    }

    var hasTextReplacementAccess: Bool {
        textReplacementService.hasAccess
    }

    init() {
        setupFileWatcher()
    }

    func loadSnippets() {
        do {
            rootFolder = try fileService.loadSnippetTree()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func syncToTextReplacement() {
        guard let root = rootFolder else { return }

        syncStatus = .syncing

        do {
            let snippets = root.allSnippets.filter { $0.enabled }
            let result = try textReplacementService.syncSnippets(snippets)
            syncStatus = .synced
            notificationService.showSyncSuccess(count: result.total)

            Task {
                try? await Task.sleep(for: .seconds(2))
                if syncStatus == .synced {
                    syncStatus = .idle
                }
            }

            if result.total > 0 {
                errorMessage = nil
            }
        } catch {
            syncStatus = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
            notificationService.showError(title: "Sync Failed", message: error.localizedDescription)
        }
    }

    func copyToClipboard(_ snippet: Snippet) {
        let expandedContent = VariableService.expand(snippet.content)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(expandedContent, forType: .string)
    }

    func createNewSnippet(named name: String, shortcut: String, in folder: SnippetFolder) {
        do {
            _ = try fileService.createSnippet(named: name, shortcut: shortcut, in: folder)
            loadSnippets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createNewFolder(named name: String, in parent: SnippetFolder) {
        do {
            _ = try fileService.createFolder(named: name, in: parent)
            loadSnippets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteSnippet(_ snippet: Snippet) {
        do {
            try fileService.deleteSnippet(snippet)
            loadSnippets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteFolder(_ folder: SnippetFolder) {
        do {
            try fileService.deleteFolder(folder)
            loadSnippets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openSnippetsFolder() {
        NSWorkspace.shared.open(fileService.snippetsDirectory)
    }

    func openFullDiskAccessSettings() {
        textReplacementService.openFullDiskAccessSettings()
    }

    func fileWatcherDidDetectChanges(_ watcher: FileWatcherService) {
        loadSnippets()
    }

    func isExpanded(_ folder: SnippetFolder) -> Bool {
        expandedFolderIDs.contains(folder.id)
    }

    func toggleExpanded(_ folder: SnippetFolder) {
        if expandedFolderIDs.contains(folder.id) {
            expandedFolderIDs.remove(folder.id)
        } else {
            expandedFolderIDs.insert(folder.id)
        }
    }

    private func setupFileWatcher() {
        fileWatcher = FileWatcherService(url: fileService.snippetsDirectory)
        fileWatcher?.delegate = self
        fileWatcher?.start()
    }

    private func filterFolder(_ folder: SnippetFolder?, searchText: String) -> SnippetFolder? {
        guard let folder = folder else { return nil }

        let matchingSnippets = folder.snippets.filter { snippet in
            snippet.fileName.lowercased().contains(searchText) ||
            snippet.shortcut.lowercased().contains(searchText) ||
            snippet.content.lowercased().contains(searchText)
        }

        let matchingChildren = folder.children.compactMap { child in
            filterFolder(child, searchText: searchText)
        }

        if matchingSnippets.isEmpty && matchingChildren.isEmpty {
            return nil
        }

        return SnippetFolder(
            id: folder.id,
            name: folder.name,
            path: folder.path,
            children: matchingChildren,
            snippets: matchingSnippets
        )
    }
}
