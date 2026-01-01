import Foundation
import ServiceManagement
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var launchAtLogin: Bool {
        didSet {
            updateLaunchAtLogin()
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
        }
    }

    var autoSync: Bool {
        didSet {
            UserDefaults.standard.set(autoSync, forKey: Keys.autoSync)
        }
    }

    var snippetsDirectory: URL {
        SnippetFileService.defaultSnippetsDirectory
    }

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let autoSync = "autoSync"
    }

    init() {
        self.launchAtLogin = UserDefaults.standard.bool(forKey: Keys.launchAtLogin)
        self.autoSync = UserDefaults.standard.bool(forKey: Keys.autoSync)

        syncLaunchAtLoginState()
    }

    private func syncLaunchAtLoginState() {
        let currentStatus = SMAppService.mainApp.status
        let isEnabled = currentStatus == .enabled

        if launchAtLogin != isEnabled {
            launchAtLogin = isEnabled
        }
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            syncLaunchAtLoginState()
        }
    }

    func resetToDefaults() {
        launchAtLogin = false
        autoSync = false
    }
}
