import SwiftUI

struct FolderRowView: View {
    let folder: SnippetFolder
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                onToggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(width: 12)

                Image(systemName: isExpanded ? "folder.fill" : "folder")
                    .foregroundStyle(.secondary)

                Text(folder.name)
                    .font(.body)
                    .lineLimit(1)

                Spacer()

                Text("\(folder.snippetCount)")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(.tertiary)
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 0) {
        FolderRowView(
            folder: SnippetFolder(
                name: "Work",
                path: URL(fileURLWithPath: "/tmp/work"),
                snippets: [
                    Snippet(shortcut: ";email", content: "test@example.com", filePath: URL(fileURLWithPath: "/tmp/email.md")),
                    Snippet(shortcut: ";sig", content: "Best regards", filePath: URL(fileURLWithPath: "/tmp/sig.md"))
                ]
            ),
            isExpanded: true,
            onToggle: {}
        )

        FolderRowView(
            folder: SnippetFolder(
                name: "Personal",
                path: URL(fileURLWithPath: "/tmp/personal"),
                snippets: [
                    Snippet(shortcut: ";addr", content: "123 Main St", filePath: URL(fileURLWithPath: "/tmp/addr.md"))
                ]
            ),
            isExpanded: false,
            onToggle: {}
        )
    }
    .frame(width: 320)
}
