import SwiftUI

@main
struct QuickSnipApp: App {
    var body: some Scene {
        MenuBarExtra("QuickSnip", systemImage: "doc.on.clipboard") {
            MenuBarContentView()
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsWindowView()
        }
    }
}
