import SwiftUI

@main
struct QuickSnipApp: App {
    @State private var snippetTreeViewModel = SnippetTreeViewModel()
    @State private var settingsViewModel = SettingsViewModel()

    init() {
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        MenuBarExtra("QuickSnip", image: "MenuBarIcon") {
            MenuBarContentView(viewModel: snippetTreeViewModel)
                .environment(settingsViewModel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsWindowView(viewModel: settingsViewModel)
        }
    }
}
