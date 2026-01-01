import Foundation

struct SnippetFolder: Identifiable, Hashable {
    let id: UUID
    let name: String
    let path: URL
    let children: [SnippetFolder]
    let snippets: [Snippet]

    init(
        id: UUID = UUID(),
        name: String,
        path: URL,
        children: [SnippetFolder] = [],
        snippets: [Snippet] = []
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.children = children
        self.snippets = snippets
    }
}

extension SnippetFolder {
    var allSnippets: [Snippet] {
        snippets + children.flatMap(\.allSnippets)
    }

    var allFolders: [SnippetFolder] {
        [self] + children.flatMap(\.allFolders)
    }

    var snippetCount: Int {
        allSnippets.count
    }
}
