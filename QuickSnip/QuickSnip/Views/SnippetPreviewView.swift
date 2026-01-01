import SwiftUI

struct SnippetPreviewView: View {
    let snippet: Snippet
    var onCopy: ((Snippet) -> Void)?
    var onEdit: ((Snippet) -> Void)?
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

            Divider()

            contentView

            if snippet.category != nil {
                categoryView
            }

            Divider()

            actionButtons
        }
        .padding()
        .frame(width: 320)
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(snippet.fileName)
                    .font(.headline)

                if !snippet.enabled {
                    Label("Disabled", systemImage: "pause.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(snippet.shortcut)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    private var contentView: some View {
        ScrollView {
            Text(snippet.content)
                .font(.body)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 200)
    }

    @ViewBuilder
    private var categoryView: some View {
        if let category = snippet.category {
            HStack {
                Image(systemName: "tag")
                    .font(.caption)
                Text(category)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
    }

    private var actionButtons: some View {
        HStack {
            if let onCopy = onCopy {
                Button {
                    onCopy(snippet)
                    onDismiss?()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderedProminent)
            }

            if let onEdit = onEdit {
                Button {
                    onEdit(snippet)
                    onDismiss?()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Text(snippet.lastModified, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    SnippetPreviewView(
        snippet: Snippet(
            shortcut: ";sig",
            content: "Best regards,\nPascal\n\nSenior Developer\nExample Corp",
            category: "work",
            filePath: URL(fileURLWithPath: "/tmp/sig.md")
        ),
        onCopy: { _ in },
        onEdit: { _ in },
        onDismiss: { }
    )
}
