import SwiftUI

struct SettingsWindowView: View {
    @Bindable var viewModel: SettingsViewModel

    private let textReplacementService = TextReplacementService()

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at Login", isOn: $viewModel.launchAtLogin)
                Toggle("Auto-sync to Text Replacement", isOn: $viewModel.autoSync)
            }

            Section("Snippets") {
                LabeledContent("Location") {
                    Text(viewModel.snippetsDirectory.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                Button("Open Snippets Folder") {
                    NSWorkspace.shared.open(viewModel.snippetsDirectory)
                }
            }

            Section("Text Replacement") {
                HStack {
                    if textReplacementService.hasAccess {
                        Label("Full Disk Access granted", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Label("Full Disk Access required", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }

                    Spacer()

                    Button("Open Settings") {
                        textReplacementService.openFullDiskAccessSettings()
                    }
                }

                Text("QuickSnip needs Full Disk Access to sync snippets to macOS Text Replacement.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                LabeledContent("Version") {
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Build") {
                    Text(buildNumber)
                        .foregroundStyle(.secondary)
                }

                Link("GitHub Repository", destination: URL(string: "https://github.com/pasogott/quicksnip-menubar-swift")!)
            }

            Section {
                Button("Reset to Defaults", role: .destructive) {
                    viewModel.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 420)
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
}

#Preview {
    SettingsWindowView(viewModel: SettingsViewModel())
}
