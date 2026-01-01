# QuickSnip Architecture

## Overview

QuickSnip is a native macOS menubar application built with Swift and SwiftUI. It manages text snippets stored as markdown files and syncs them to macOS native Text Replacement.

## Design Principles

1. **No External Dependencies** - Pure Swift with native macOS APIs only
2. **Files as Source of Truth** - Snippets are markdown files, editable anywhere
3. **Native Integration** - Leverages macOS Text Replacement + iCloud sync
4. **Simplicity** - Minimal UI, maximum utility

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      QuickSnipApp                           │
│                    (MenuBarExtra)                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  SnippetTreeViewModel                       │
│              (Main State Management)                        │
└─────────────────────────────────────────────────────────────┘
          │              │              │              │
          ▼              ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│SnippetFile   │ │FileWatcher   │ │TextReplace   │ │ImportExport  │
│Service       │ │Service       │ │mentService   │ │Service       │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
       │                │                │                │
       ▼                ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│~/.snippets/  │ │FSEvents API  │ │SQLite DB     │ │.zip files    │
│*.md files    │ │              │ │KeyboardSvc   │ │              │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

## Project Structure

```
QuickSnip/
├── QuickSnipApp.swift                # @main entry point, MenuBarExtra scene
│
├── Models/
│   ├── Snippet.swift                 # Snippet data model
│   ├── SnippetFolder.swift           # Folder tree node (ObservableObject)
│   └── SyncStatus.swift              # Sync state enum
│
├── Services/
│   ├── SnippetFileService.swift      # File I/O, tree loading
│   ├── MarkdownParser.swift          # YAML frontmatter extraction
│   ├── FileWatcherService.swift      # FSEvents wrapper for live reload
│   ├── TextReplacementService.swift  # SQLite sync to macOS
│   ├── VariableService.swift         # Expand {date}, {time}, {clipboard}
│   └── ImportExportService.swift     # Zip import/export
│
├── ViewModels/
│   ├── SnippetTreeViewModel.swift    # Main app state
│   └── SettingsViewModel.swift       # Settings state
│
├── Views/
│   ├── MenuBarContentView.swift      # Main popover content
│   ├── SnippetTreeView.swift         # Recursive folder/snippet tree
│   ├── SnippetRowView.swift          # Single snippet row
│   ├── FolderRowView.swift           # Folder row with disclosure
│   ├── SnippetPreviewView.swift      # Long-press preview popover
│   └── SettingsWindowView.swift      # Settings window
│
└── Resources/
    ├── Assets.xcassets               # App icons
    └── Info.plist                    # App configuration
```

## Data Flow

### Reading Snippets

```
1. App launches
2. SnippetFileService.loadSnippetTree()
3. Recursively scan ~/.snippets/
4. Parse each .md file with MarkdownParser
5. Build SnippetFolder tree
6. Update SnippetTreeViewModel.rootFolder
7. SwiftUI views re-render
```

### File Change Detection

```
1. FileWatcherService monitors ~/.snippets/ via FSEvents
2. File change detected
3. Debounce 0.5s
4. Trigger SnippetTreeViewModel.loadSnippets()
5. Tree rebuilt, UI updated
```

### Copying a Snippet

```
1. User clicks snippet row
2. SnippetRowView.onTapGesture triggered
3. VariableService.expand(snippet.content)
4. Replace {date}, {time}, {clipboard}
5. NSPasteboard.general.setString()
6. Brief visual feedback
```

### Syncing to Text Replacement

```
1. User clicks "Sync Now"
2. TextReplacementService.syncSnippets()
3. Open ~/Library/KeyboardServices/TextReplacements.db
4. For each enabled snippet:
   - Check if shortcut exists → UPDATE
   - Otherwise → INSERT
5. Touch database file to trigger iCloud sync
6. Show notification (restart may be needed)
```

## Key Technical Decisions

### Why Direct SQLite?

The macOS Text Replacement system stores data in a SQLite database. While Apple provides no public API, direct database access is reliable and allows programmatic updates without user interaction.

**Location:** `~/Library/KeyboardServices/TextReplacements.db`

**Trade-off:** Requires Full Disk Access permission and changes may need a restart to take effect.

### Why FSEvents?

FSEvents is the native macOS API for file system monitoring. It's efficient, recursive, and requires no external dependencies.

### Why YAML Frontmatter?

The `---` delimited YAML frontmatter format is widely used (Jekyll, Hugo, Obsidian). It allows metadata (shortcut, category, enabled) to coexist with content in a single, human-readable file.

### Why Non-Sandboxed?

App Sandbox prevents access to:
- `~/Library/KeyboardServices/` (Text Replacement database)
- Arbitrary file locations

Distribution outside App Store with notarization is required.

## Configuration

### Info.plist

| Key | Value | Purpose |
|-----|-------|---------|
| `LSUIElement` | `true` | No dock icon (menubar only) |
| `LSMinimumSystemVersion` | `15.0` | Require macOS Sequoia |

### Entitlements

| Entitlement | Value | Purpose |
|-------------|-------|---------|
| `com.apple.security.app-sandbox` | `false` | Disable sandbox |
| `com.apple.security.files.user-selected.read-write` | `true` | File access |

## Security Considerations

1. **Full Disk Access** - Required for Text Replacement sync. App prompts user to grant in System Settings.

2. **No Network Access** - App is entirely local. No data leaves the device.

3. **Notarization** - App will be notarized by Apple for safe distribution.

## Performance Considerations

1. **Debounced File Watching** - 0.5s delay prevents excessive reloads during rapid edits.

2. **Lazy Tree Loading** - Large folder structures load children on-demand.

3. **Background Sync** - Text Replacement sync runs on background thread.
