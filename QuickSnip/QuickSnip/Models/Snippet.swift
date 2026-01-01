import Foundation

struct Snippet: Identifiable, Codable, Hashable {
    let id: UUID
    var shortcut: String
    var content: String
    var category: String?
    var enabled: Bool
    let filePath: URL
    var lastModified: Date

    var fileName: String {
        filePath.deletingPathExtension().lastPathComponent
    }

    init(
        id: UUID = UUID(),
        shortcut: String,
        content: String,
        category: String? = nil,
        enabled: Bool = true,
        filePath: URL,
        lastModified: Date = Date()
    ) {
        self.id = id
        self.shortcut = shortcut
        self.content = content
        self.category = category
        self.enabled = enabled
        self.filePath = filePath
        self.lastModified = lastModified
    }

    init?(from fileURL: URL) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        guard let parsed = MarkdownParser.parse(fileAt: fileURL) else {
            return nil
        }

        let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        let modDate = attributes?[.modificationDate] as? Date ?? Date()

        self.id = UUID()
        self.shortcut = parsed.shortcut
        self.content = parsed.content
        self.category = parsed.category
        self.enabled = parsed.enabled
        self.filePath = fileURL
        self.lastModified = modDate
    }
}
