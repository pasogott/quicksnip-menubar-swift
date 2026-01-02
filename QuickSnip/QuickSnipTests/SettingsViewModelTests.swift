import XCTest
@testable import QuickSnip

@MainActor
final class SettingsViewModelTests: XCTestCase {

    private func makeMock() -> MockTextReplacementService {
        MockTextReplacementService()
    }

    private func resetDefaults() {
        UserDefaults.standard.removeObject(forKey: "autoSync")
        UserDefaults.standard.removeObject(forKey: "launchAtLogin")
    }

    // MARK: - Initialization Tests

    func test_init_defaultsAutoSyncToFalse() {
        resetDefaults()
        let viewModel = SettingsViewModel(textReplacementService: makeMock())

        XCTAssertFalse(viewModel.autoSync)
    }

    func test_init_loadsAutoSyncFromUserDefaults() {
        resetDefaults()
        UserDefaults.standard.set(true, forKey: "autoSync")

        let viewModel = SettingsViewModel(textReplacementService: makeMock())

        XCTAssertTrue(viewModel.autoSync)
    }

    // MARK: - Auto Sync Tests

    func test_autoSync_persistsToUserDefaults() {
        resetDefaults()
        let viewModel = SettingsViewModel(textReplacementService: makeMock())

        viewModel.autoSync = true

        XCTAssertTrue(UserDefaults.standard.bool(forKey: "autoSync"))
    }

    func test_autoSync_canBeToggled() {
        resetDefaults()
        let viewModel = SettingsViewModel(textReplacementService: makeMock())

        viewModel.autoSync = true
        XCTAssertTrue(viewModel.autoSync)

        viewModel.autoSync = false
        XCTAssertFalse(viewModel.autoSync)
    }

    // MARK: - Snippets Directory Tests

    func test_snippetsDirectory_returnsDefaultPath() {
        let viewModel = SettingsViewModel(textReplacementService: makeMock())

        let expected = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".snippets", isDirectory: true)

        XCTAssertEqual(viewModel.snippetsDirectory, expected)
    }

    func test_snippetsDirectory_matchesSnippetFileServiceDefault() {
        let viewModel = SettingsViewModel(textReplacementService: makeMock())

        XCTAssertEqual(viewModel.snippetsDirectory, SnippetFileService.defaultSnippetsDirectory)
    }

    // MARK: - Full Disk Access Tests

    func test_hasFullDiskAccess_returnsServiceValue_whenTrue() {
        let mock = makeMock()
        mock.hasAccess = true
        let viewModel = SettingsViewModel(textReplacementService: mock)

        XCTAssertTrue(viewModel.hasFullDiskAccess)
    }

    func test_hasFullDiskAccess_returnsServiceValue_whenFalse() {
        let mock = makeMock()
        mock.hasAccess = false
        let viewModel = SettingsViewModel(textReplacementService: mock)

        XCTAssertFalse(viewModel.hasFullDiskAccess)
    }

    func test_openFullDiskAccessSettings_callsService() {
        var openSettingsCalled = false
        let mockService = TrackingTextReplacementService(onOpenSettings: {
            openSettingsCalled = true
        })
        let viewModel = SettingsViewModel(textReplacementService: mockService)

        viewModel.openFullDiskAccessSettings()

        XCTAssertTrue(openSettingsCalled)
    }

    // MARK: - Reset to Defaults Tests

    func test_resetToDefaults_clearsAutoSync() {
        resetDefaults()
        let viewModel = SettingsViewModel(textReplacementService: makeMock())
        viewModel.autoSync = true

        viewModel.resetToDefaults()

        XCTAssertFalse(viewModel.autoSync)
    }

    func test_resetToDefaults_clearsLaunchAtLogin() {
        resetDefaults()
        let viewModel = SettingsViewModel(textReplacementService: makeMock())

        viewModel.resetToDefaults()

        XCTAssertFalse(viewModel.launchAtLogin)
    }

    func test_resetToDefaults_persistsChanges() {
        resetDefaults()
        let viewModel = SettingsViewModel(textReplacementService: makeMock())
        viewModel.autoSync = true

        viewModel.resetToDefaults()

        XCTAssertFalse(UserDefaults.standard.bool(forKey: "autoSync"))
    }
}

// MARK: - Test Helpers

private final class TrackingTextReplacementService: TextReplacementServiceProtocol, @unchecked Sendable {
    var hasAccess: Bool = true
    private let onOpenSettings: () -> Void

    init(onOpenSettings: @escaping () -> Void) {
        self.onOpenSettings = onOpenSettings
    }

    func syncSnippets(_ snippets: [Snippet]) throws -> SyncResult {
        SyncResult(inserted: 0, updated: 0)
    }

    func deleteReplacement(shortcut: String) throws {}

    func openFullDiskAccessSettings() {
        onOpenSettings()
    }
}
