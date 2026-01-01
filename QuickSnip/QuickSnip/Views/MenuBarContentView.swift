import SwiftUI
import UniformTypeIdentifiers

struct MenuBarContentView: View {
    @Bindable var viewModel: SnippetTreeViewModel

    @State private var showingNewSnippetSheet = false
    @State private var showingNewFolderSheet = false
    @State private var showingImportPicker = false
    @State private var showingExportPicker = false

    var body: some View {
        VStack(spacing: 0) {
            headerView

            searchField

            Divider()

            if let error = viewModel.errorMessage {
                errorBanner(error)
            }

            contentView

            Divider()

            actionBar

            Divider()

            footerView
        }
        .frame(width: 320, height: 440)
        .onAppear {
            viewModel.loadSnippets()
        }
        .sheet(isPresented: $showingNewSnippetSheet) {
            NewSnippetSheet(viewModel: viewModel, isPresented: $showingNewSnippetSheet)
        }
        .sheet(isPresented: $showingNewFolderSheet) {
            NewFolderSheet(viewModel: viewModel, isPresented: $showingNewFolderSheet)
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.zip, .folder],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .fileExporter(
            isPresented: $showingExportPicker,
            document: SnippetExportDocument(folder: viewModel.rootFolder),
            contentType: .zip,
            defaultFilename: "snippets-export"
        ) { _ in }
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

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search snippets...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.5))
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Menu {
                Button("New Snippet", action: { showingNewSnippetSheet = true })
                Button("New Folder", action: { showingNewFolderSheet = true })
            } label: {
                Label("New", systemImage: "plus")
            }
            .menuStyle(.borderlessButton)

            Button {
                showingImportPicker = true
            } label: {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.borderless)

            Button {
                showingExportPicker = true
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.rootFolder?.snippetCount == 0)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let importService = ImportExportService()
            do {
                if url.pathExtension == "zip" {
                    _ = try importService.importFromZip(url)
                } else {
                    _ = try importService.importFolder(url)
                }
                viewModel.loadSnippets()
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
        }
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
                SnippetTreeView(folder: root) { snippet in
                    viewModel.copyToClipboard(snippet)
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

private struct NewSnippetSheet: View {
    let viewModel: SnippetTreeViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var shortcut = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("New Snippet")
                .font(.headline)

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Shortcut (e.g., ;sig)", text: $shortcut)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Create") {
                    if let root = viewModel.rootFolder {
                        viewModel.createNewSnippet(named: name, shortcut: shortcut, in: root)
                    }
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty || shortcut.isEmpty)
            }
        }
        .padding()
        .frame(width: 280)
    }
}

private struct NewFolderSheet: View {
    let viewModel: SnippetTreeViewModel
    @Binding var isPresented: Bool
    @State private var name = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("New Folder")
                .font(.headline)

            TextField("Folder Name", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Create") {
                    if let root = viewModel.rootFolder {
                        viewModel.createNewFolder(named: name, in: root)
                    }
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 280)
    }
}

struct SnippetExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.zip] }

    nonisolated(unsafe) let folder: SnippetFolder?

    init(folder: SnippetFolder?) {
        self.folder = folder
    }

    init(configuration: ReadConfiguration) throws {
        self.folder = nil
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let folder = folder else {
            throw CocoaError(.fileWriteUnknown)
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".zip")

        let exportService = ImportExportService()
        try exportService.exportToZip(folder: folder, destination: tempURL)

        let data = try Data(contentsOf: tempURL)
        try? FileManager.default.removeItem(at: tempURL)

        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    MenuBarContentView(viewModel: SnippetTreeViewModel())
}
