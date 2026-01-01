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

        guard let data = try? Data(contentsOf: fileURL),
              let fileContent = String(data: data, encoding: .utf8) else {
            return nil
        }

        guard let parsed = Self.parseFrontmatter(fileContent) else {
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

    private static func parseFrontmatter(_ text: String) -> (shortcut: String, content: String, category: String?, enabled: Bool)? {
        let delimiter = "---"
        let lines = text.components(separatedBy: .newlines)

        guard lines.first == delimiter else {
            return nil
        }

        var endIndex: Int?
        for (index, line) in lines.dropFirst().enumerated() {
            if line == delimiter {
                endIndex = index + 1
                break
            }
        }

        guard let end = endIndex else {
            return nil
        }

        let frontmatterLines = Array(lines[1..<end])
        let contentLines = Array(lines[(end + 1)...])
        let content = contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        var shortcut: String?
        var category: String?
        var enabled = true

        for line in frontmatterLines {
            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { continue }

            let key = parts[0].trimmingCharacters(in: .whitespaces).lowercased()
            let value = parts[1].trimmingCharacters(in: .whitespaces)

            switch key {
            case "shortcut":
                shortcut = value
            case "category":
                category = value.isEmpty ? nil : value
            case "enabled":
                enabled = value.lowercased() != "false"
            default:
                break
            }
        }

        guard let sc = shortcut, !sc.isEmpty else {
            return nil
        }

        return (sc, content, category, enabled)
    }
}
