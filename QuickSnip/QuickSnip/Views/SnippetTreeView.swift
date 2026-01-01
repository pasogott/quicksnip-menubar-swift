import SwiftUI

struct SnippetTreeView: View {
    let folder: SnippetFolder
    let onSnippetCopy: (Snippet) -> Void
    var onSnippetEdit: ((Snippet) -> Void)?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(folder.snippets) { snippet in
                    SnippetRowView(
                        snippet: snippet,
                        onCopy: onSnippetCopy,
                        onEdit: onSnippetEdit
                    )
                }
                ForEach(folder.children) { childFolder in
                    FolderSection(
                        folder: childFolder,
                        onSnippetCopy: onSnippetCopy,
                        onSnippetEdit: onSnippetEdit
                    )
                }
            }
        }
    }
}

private struct FolderSection: View {
    let folder: SnippetFolder
    let onSnippetCopy: (Snippet) -> Void
    var onSnippetEdit: ((Snippet) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            FolderRowView(
                folder: folder,
                isExpanded: Binding(
                    get: { folder.isExpanded },
                    set: { folder.isExpanded = $0 }
                )
            )

            if folder.isExpanded {
                ForEach(folder.snippets) { snippet in
                    SnippetRowView(
                        snippet: snippet,
                        onCopy: onSnippetCopy,
                        onEdit: onSnippetEdit
                    )
                    .padding(.leading, 20)
                }
                ForEach(folder.children) { child in
                    FolderSection(
                        folder: child,
                        onSnippetCopy: onSnippetCopy,
                        onSnippetEdit: onSnippetEdit
                    )
                    .padding(.leading, 20)
                }
            }
        }
    }
}

#Preview {
    let folder = SnippetFolder(
        name: "Root",
        path: URL(fileURLWithPath: "/tmp"),
        children: [
            SnippetFolder(
                name: "Work",
                path: URL(fileURLWithPath: "/tmp/work"),
                snippets: [
                    Snippet(
                        shortcut: ";email",
                        content: "test@example.com",
                        filePath: URL(fileURLWithPath: "/tmp/email.md")
                    )
                ]
            )
        ],
        snippets: [
            Snippet(
                shortcut: ";sig",
                content: "Best regards",
                filePath: URL(fileURLWithPath: "/tmp/sig.md")
            )
        ]
    )

    return SnippetTreeView(
        folder: folder,
        onSnippetCopy: { snippet in
            print("Copy: \(snippet.shortcut)")
        },
        onSnippetEdit: { snippet in
            print("Edit: \(snippet.shortcut)")
        }
    )
    .frame(width: 320, height: 300)
}
