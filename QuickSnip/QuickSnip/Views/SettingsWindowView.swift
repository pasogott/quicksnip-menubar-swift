import SwiftUI

struct SettingsWindowView: View {
    @Bindable var viewModel: SettingsViewModel

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

            Section {
                Button("Reset to Defaults", role: .destructive) {
                    viewModel.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 280)
    }
}

#Preview {
    SettingsWindowView(viewModel: SettingsViewModel())
}
