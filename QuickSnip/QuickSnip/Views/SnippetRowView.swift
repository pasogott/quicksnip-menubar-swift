import SwiftUI

struct SnippetRowView: View {
    let snippet: Snippet
    let onCopy: (Snippet) -> Void
    var onEdit: ((Snippet) -> Void)?

    @State private var isHovering = false
    @State private var showingPreview = false

    var body: some View {
        Button {
            onCopy(snippet)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(snippet.fileName)
                        .font(.body)
                        .foregroundStyle(snippet.enabled ? .primary : .secondary)
                    Text(snippet.shortcut)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isHovering {
                    hoverActions
                } else {
                    statusIndicator
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .background(isHovering ? Color.accentColor.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            showingPreview = true
        }
        .popover(isPresented: $showingPreview, arrowEdge: .trailing) {
            SnippetPreviewView(
                snippet: snippet,
                onCopy: onCopy,
                onEdit: onEdit,
                onDismiss: { showingPreview = false }
            )
        }
    }

    @ViewBuilder
    private var statusIndicator: some View {
        if !snippet.enabled {
            Image(systemName: "pause.circle")
                .foregroundStyle(.secondary)
        }
    }

    private var hoverActions: some View {
        HStack(spacing: 8) {
            Button {
                onCopy(snippet)
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Copy to clipboard")

            if let onEdit = onEdit {
                Button {
                    onEdit(snippet)
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .help("Edit snippet")
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SnippetRowView(
            snippet: Snippet(
                shortcut: ";sig",
                content: "Best regards,\nPascal",
                filePath: URL(fileURLWithPath: "/tmp/sig.md")
            ),
            onCopy: { _ in },
            onEdit: { _ in }
        )

        SnippetRowView(
            snippet: Snippet(
                shortcut: ";disabled",
                content: "Disabled snippet",
                enabled: false,
                filePath: URL(fileURLWithPath: "/tmp/disabled.md")
            ),
            onCopy: { _ in }
        )
    }
    .frame(width: 320)
}
