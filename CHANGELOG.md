# Changelog

All notable changes to this project will be documented in this file.

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
