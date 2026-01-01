import Foundation

struct SnippetFileService: SnippetFileServiceProtocol {
    let snippetsDirectory: URL

    private var fileManager: FileManager { FileManager.default }

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.snippetsDirectory = home.appendingPathComponent(".snippets", isDirectory: true)
    }

    func ensureSnippetsDirectoryExists() throws {
        if !fileManager.fileExists(atPath: snippetsDirectory.path) {
            try fileManager.createDirectory(at: snippetsDirectory, withIntermediateDirectories: true)
        }
    }

    func loadSnippetTree() throws -> SnippetFolder {
        try ensureSnippetsDirectoryExists()
        return try loadFolder(at: snippetsDirectory)
    }

    private func loadFolder(at url: URL) throws -> SnippetFolder {
        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        var subfolders: [SnippetFolder] = []
        var snippets: [Snippet] = []

        for item in contents {
            let resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey])
            let isDirectory = resourceValues.isDirectory ?? false

            if isDirectory {
                let subfolder = try loadFolder(at: item)
                subfolders.append(subfolder)
            } else if item.pathExtension == "md" {
                if let snippet = snippetFromFile(item) {
                    snippets.append(snippet)
                }
            }
        }

        subfolders.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        snippets.sort { $0.fileName.localizedCaseInsensitiveCompare($1.fileName) == .orderedAscending }

        return SnippetFolder(
            name: url.lastPathComponent,
            path: url,
            children: subfolders,
            snippets: snippets
        )
    }

    func createSnippet(named name: String, shortcut: String, in folder: SnippetFolder) throws -> Snippet {
        let fileName = sanitizeFileName(name) + ".md"
        let fileURL = folder.path.appendingPathComponent(fileName)

        let content = MarkdownParser.generateMarkdown(
            shortcut: shortcut,
            content: "Your snippet content here"
        )

        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        guard let snippet = snippetFromFile(fileURL) else {
            throw SnippetFileError.failedToCreateSnippet
        }

        return snippet
    }

    func createFolder(named name: String, in parent: SnippetFolder) throws -> SnippetFolder {
        let folderName = sanitizeFileName(name)
        let folderURL = parent.path.appendingPathComponent(folderName, isDirectory: true)

        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)

        return SnippetFolder(
            name: folderName,
            path: folderURL
        )
    }

    func deleteSnippet(_ snippet: Snippet) throws {
        try fileManager.removeItem(at: snippet.filePath)
    }

    func deleteFolder(_ folder: SnippetFolder) throws {
        try fileManager.removeItem(at: folder.path)
    }

    func saveSnippet(_ snippet: Snippet) throws {
        let content = MarkdownParser.generateMarkdown(
            shortcut: snippet.shortcut,
            content: snippet.content,
            category: snippet.category,
            enabled: snippet.enabled
        )
        try content.write(to: snippet.filePath, atomically: true, encoding: .utf8)
    }

    func snippetFromFile(_ fileURL: URL) -> Snippet? {
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        guard let parsed = MarkdownParser.parse(fileAt: fileURL) else { return nil }

        let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
        let modDate = attributes?[.modificationDate] as? Date ?? Date()

        return Snippet(
            shortcut: parsed.shortcut,
            content: parsed.content,
            category: parsed.category,
            enabled: parsed.enabled,
            filePath: fileURL,
            lastModified: modDate
        )
    }

    private func sanitizeFileName(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/:\\")
        let sanitized = name.components(separatedBy: invalidCharacters).joined(separator: "-")
        return sanitized.trimmingCharacters(in: .whitespaces)
    }
}

enum SnippetFileError: LocalizedError {
    case failedToCreateSnippet
    case folderAlreadyExists

    var errorDescription: String? {
        switch self {
        case .failedToCreateSnippet:
            return "Failed to create snippet file"
        case .folderAlreadyExists:
            return "A folder with this name already exists"
        }
    }
}
