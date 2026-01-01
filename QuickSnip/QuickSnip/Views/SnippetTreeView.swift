import SwiftUI

struct SnippetTreeView: View {
    let folder: SnippetFolder
    @Bindable var viewModel: SnippetTreeViewModel
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
                        viewModel: viewModel,
                        onSnippetCopy: onSnippetCopy,
                        onSnippetEdit: onSnippetEdit,
                        forceExpanded: !viewModel.searchText.isEmpty
                    )
                }
            }
        }
    }
}

private struct FolderSection: View {
    let folder: SnippetFolder
    @Bindable var viewModel: SnippetTreeViewModel
    let onSnippetCopy: (Snippet) -> Void
    var onSnippetEdit: ((Snippet) -> Void)?
    var forceExpanded: Bool = false

    private var isExpanded: Bool {
        forceExpanded || viewModel.isExpanded(folder)
    }

    var body: some View {
        VStack(spacing: 0) {
            FolderRowView(
                folder: folder,
                isExpanded: isExpanded,
                onToggle: { viewModel.toggleExpanded(folder) }
            )

            if isExpanded {
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
                        viewModel: viewModel,
                        onSnippetCopy: onSnippetCopy,
                        onSnippetEdit: onSnippetEdit,
                        forceExpanded: forceExpanded
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
        viewModel: SnippetTreeViewModel(),
        onSnippetCopy: { snippet in
            print("Copy: \(snippet.shortcut)")
        },
        onSnippetEdit: { snippet in
            print("Edit: \(snippet.shortcut)")
        }
    )
    .frame(width: 320, height: 300)
}
