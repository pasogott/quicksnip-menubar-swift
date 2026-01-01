import SwiftUI

@main
struct QuickSnipApp: App {
    @State private var snippetTreeViewModel = SnippetTreeViewModel()
    @State private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        MenuBarExtra("QuickSnip", systemImage: "doc.on.clipboard") {
            MenuBarContentView(viewModel: snippetTreeViewModel)
                .environment(settingsViewModel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsWindowView(viewModel: settingsViewModel)
        }
    }
}
