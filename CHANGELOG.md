# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1] - 2026-01-02

### Fixed
- Text Replacement sync now works correctly with iCloud (#74)
  - Added missing ZUNIQUENAME (UUID) field required by CloudKit
  - Added ZNEEDSSAVETOCLOUD flag to trigger iCloud sync
  - Added Z_PRIMARYKEY update for database consistency
  - Added SQLite WAL checkpoint for immediate persistence
- Text Replacements now activate immediately after sync (#76)
  - Added GlobalPreferences.plist update for local activation
  - Fixed to use globalDomain instead of standard UserDefaults
  - Added keyboardservicesd daemon restart
- Full Disk Access detection now correctly identifies permission status (#73)
  - Changed from read-based to write-based access test
  - Tests write access in KeyboardServices directory instead of Safari proxy

### Documentation
- Added Architecture Decision Record explaining why direct database access is used instead of InputMethodKit or Event Taps (the only approach that enables iOS sync via iCloud)

## [1.0.0] - 2026-01-01

### Features
- Markdown-based snippet storage in `~/.snippets/`
- Sync to macOS Text Replacement (syncs to iOS via iCloud)
- Variable expansion: `{date}`, `{time}`, `{clipboard}`
- Import/export snippets as zip archives
- Folder organization with nested snippets
- Live file watching with auto-reload
- Search across shortcuts and content
- Keyboard shortcuts: Cmd+N (new snippet), Cmd+Shift+N (new folder), Cmd+R (sync)
- System notifications for sync and import operations
- Settings with launch at login and auto-sync options

### Components
- **Models**: Snippet, SnippetFolder, SyncStatus
- **Services**: SnippetFileService, MarkdownParser, FileWatcherService, TextReplacementService, SQLiteDatabase, VariableService, ImportExportService, NotificationService
- **ViewModels**: SnippetTreeViewModel, SettingsViewModel
- **Views**: MenuBarContentView, SnippetTreeView, SnippetRowView, FolderRowView, SnippetPreviewView, SettingsWindowView

### Quality
- 150 tests with 93% test-to-source ratio
- Full SOLID compliance with protocol-based dependency injection
- Parameterized SQL queries for security

### Requirements
- macOS 15.0+ (Sequoia)
- Full Disk Access permission for Text Replacement sync
