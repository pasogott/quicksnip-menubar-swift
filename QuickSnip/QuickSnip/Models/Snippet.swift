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
}
