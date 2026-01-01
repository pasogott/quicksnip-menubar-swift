# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- FolderRowView: Folder row with disclosure indicator, icon, name, and count badge
- SnippetRowView: Snippet row with hover actions, long-press preview, and edit support
- SnippetTreeView: Recursive tree component for folder hierarchy display
- QuickSnipApp: Main entry point with MenuBarExtra and Settings scene
- MenuBarContentView: Full menubar popover with snippet tree, search, sync, import/export, and copy functionality
- SettingsWindowView: Settings UI with launch at login and auto-sync toggles
- SettingsViewModel: Settings state with launch at login (SMAppService) and auto-sync toggle
- SnippetTreeViewModel: Main app state management with file watcher integration and search filtering
- ImportExportService: Zip export/import and folder import with conflict handling
- VariableService: Variable expansion for {date}, {time}, {clipboard}
- TextReplacementService: SQLite sync to macOS Text Replacement database
- SQLiteDatabase: Lightweight SQLite wrapper for database operations
- FileWatcherService: FSEvents-based file system monitoring with debounce
- SnippetFileService: File I/O and snippet tree loading
- MarkdownParser: YAML frontmatter parsing and generation
- SyncStatus: Sync state enum with UI helpers
- SnippetFolder: Observable folder tree node model
- Snippet: Core snippet data model with file initialization
- Initial Xcode project setup with menubar app configuration
