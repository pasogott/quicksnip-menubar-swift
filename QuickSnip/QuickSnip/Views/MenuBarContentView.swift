import SwiftUI

struct MenuBarContentView: View {
    @Bindable var viewModel: SnippetTreeViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerView

            Divider()

            if let error = viewModel.errorMessage {
                errorBanner(error)
            }

            contentView

            Divider()

            footerView
        }
        .frame(width: 320, height: 400)
        .onAppear {
            viewModel.loadSnippets()
        }
    }

    private var headerView: some View {
        HStack {
            Text("QuickSnip")
                .font(.headline)

            Spacer()

            Button(action: viewModel.syncToTextReplacement) {
                Image(systemName: viewModel.syncStatus.symbolName)
            }
            .buttonStyle(.borderless)
            .help(viewModel.syncStatus.description)

            Button(action: viewModel.openSnippetsFolder) {
                Image(systemName: "folder")
            }
            .buttonStyle(.borderless)
            .help("Open snippets folder")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(message)
                .font(.caption)
                .lineLimit(2)
            Spacer()
            Button("Dismiss") {
                viewModel.errorMessage = nil
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(8)
        .background(.yellow.opacity(0.1))
    }

    private var contentView: some View {
        Group {
            if let root = viewModel.filteredRootFolder {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(root.snippets) { snippet in
                            SnippetRowButton(snippet: snippet, viewModel: viewModel)
                        }
                        ForEach(root.children) { folder in
                            FolderView(folder: folder, viewModel: viewModel)
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("No Snippets", systemImage: "doc.text")
                } description: {
                    Text("Add snippets to ~/.snippets/")
                }
            }
        }
    }

    private var footerView: some View {
        HStack {
            if let count = viewModel.rootFolder?.snippetCount {
                Text("\(count) snippets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            SettingsLink {
                Image(systemName: "gear")
            }
            .buttonStyle(.borderless)

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Image(systemName: "power")
            }
            .buttonStyle(.borderless)
            .help("Quit QuickSnip")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

private struct SnippetRowButton: View {
    let snippet: Snippet
    let viewModel: SnippetTreeViewModel

    var body: some View {
        Button {
            viewModel.copyToClipboard(snippet)
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

private struct FolderView: View {
    let folder: SnippetFolder
    let viewModel: SnippetTreeViewModel

    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { folder.isExpanded },
            set: { folder.isExpanded = $0 }
        )) {
            ForEach(folder.snippets) { snippet in
                SnippetRowButton(snippet: snippet, viewModel: viewModel)
                    .padding(.leading, 12)
            }
            ForEach(folder.children) { child in
                FolderView(folder: child, viewModel: viewModel)
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
    MenuBarContentView(viewModel: SnippetTreeViewModel())
}
