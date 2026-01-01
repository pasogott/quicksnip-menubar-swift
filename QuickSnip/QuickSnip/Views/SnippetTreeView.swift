import SwiftUI

struct SnippetTreeView: View {
    let folder: SnippetFolder
    let onSnippetTap: (Snippet) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(folder.snippets) { snippet in
                    SnippetRow(snippet: snippet, onTap: onSnippetTap)
                }
                ForEach(folder.children) { childFolder in
                    FolderSection(folder: childFolder, onSnippetTap: onSnippetTap)
                }
            }
        }
    }
}

private struct SnippetRow: View {
    let snippet: Snippet
    let onTap: (Snippet) -> Void

    var body: some View {
        Button {
            onTap(snippet)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(snippet.fileName)
                        .font(.body)
                    Text(snippet.shortcut)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !snippet.enabled {
                    Image(systemName: "pause.circle")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct FolderSection: View {
    let folder: SnippetFolder
    let onSnippetTap: (Snippet) -> Void

    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { folder.isExpanded },
            set: { folder.isExpanded = $0 }
        )) {
            ForEach(folder.snippets) { snippet in
                SnippetRow(snippet: snippet, onTap: onSnippetTap)
                    .padding(.leading, 12)
            }
            ForEach(folder.children) { child in
                FolderSection(folder: child, onSnippetTap: onSnippetTap)
                    .padding(.leading, 12)
            }
        } label: {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(.secondary)
                Text(folder.name)
                    .font(.body)
                Spacer()
                Text("\(folder.snippetCount)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
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

    return SnippetTreeView(folder: folder) { snippet in
        print("Tapped: \(snippet.shortcut)")
    }
    .frame(width: 320, height: 300)
}
