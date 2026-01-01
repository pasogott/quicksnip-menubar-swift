import Foundation
import SwiftUI

@Observable
final class SnippetFolder: Identifiable, Hashable {
    let id: UUID
    var name: String
    let path: URL
    var children: [SnippetFolder]
    var snippets: [Snippet]
    var isExpanded: Bool
    weak var parent: SnippetFolder?

    var allSnippets: [Snippet] {
        var result = snippets
        for child in children {
            result.append(contentsOf: child.allSnippets)
        }
        return result
    }

    var allFolders: [SnippetFolder] {
        var result = [self]
        for child in children {
            result.append(contentsOf: child.allFolders)
        }
        return result
    }

    var snippetCount: Int {
        allSnippets.count
    }

    init(
        id: UUID = UUID(),
        name: String,
        path: URL,
        children: [SnippetFolder] = [],
        snippets: [Snippet] = [],
        isExpanded: Bool = false,
        parent: SnippetFolder? = nil
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.children = children
        self.snippets = snippets
        self.isExpanded = isExpanded
        self.parent = parent

        for child in self.children {
            child.parent = self
        }
    }

    static func == (lhs: SnippetFolder, rhs: SnippetFolder) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
