import Foundation

struct MarkdownParser {
    struct ParsedSnippet {
        let shortcut: String
        let content: String
        let category: String?
        let enabled: Bool
    }

    static func parse(_ text: String) -> ParsedSnippet? {
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

        return ParsedSnippet(shortcut: sc, content: content, category: category, enabled: enabled)
    }

    static func parse(fileAt url: URL) -> ParsedSnippet? {
        guard let data = try? Data(contentsOf: url),
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        return parse(text)
    }

    static func generateMarkdown(shortcut: String, content: String, category: String? = nil, enabled: Bool = true) -> String {
        var frontmatter = "---\n"
        frontmatter += "shortcut: \(shortcut)\n"
        if let category = category {
            frontmatter += "category: \(category)\n"
        }
        if !enabled {
            frontmatter += "enabled: false\n"
        }
        frontmatter += "---\n"
        return frontmatter + content
    }
}
