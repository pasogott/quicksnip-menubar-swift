# QuickSnip

A native macOS menubar app for managing text snippets with macOS Text Replacement sync.

## Installation

### Homebrew (recommended)

```bash
brew tap pasogott/tap
brew install --cask quicksnip
```

To update:

```bash
brew upgrade --cask quicksnip
```

### Manual Download

Download the latest DMG from [Releases](https://github.com/pasogott/quicksnip-menubar-swift/releases).

## Overview

QuickSnip stores snippets as markdown files with YAML frontmatter in `~/.snippets/`. It provides a hierarchical tree view, file watching for external edits, import/export for sharing, and integration with macOS native Text Replacement.

## Features

- **Menubar Tree View** - Recursive folder/snippet hierarchy
- **File Watcher** - Auto-reload on external edits
- **Text Replacement Sync** - Syncs to macOS native system and iOS via iCloud
- **Import/Export** - Share snippets as .zip files
- **Click to Copy** - Click snippet to copy, long-press to preview
- **Variable Support** - `{date}`, `{time}`, `{clipboard}` expanded when copied
- **Edit Anywhere** - Open any .md file in your favorite editor

## Snippet Format

```markdown
---
shortcut: ;sig
category: personal
enabled: true
---
Best regards,
Pascal
```

## Folder Structure

```
~/.snippets/
├── personal/
│   ├── signature.md
│   └── address.md
├── sales/
│   └── meeting-request.md
└── quick.md
```

## Requirements

- macOS 15.0 (Sequoia) or later
- Full Disk Access permission (for Text Replacement sync)

### First Launch (Gatekeeper)

QuickSnip is not signed with an Apple Developer certificate. On first launch, macOS will show a warning saying it cannot verify the app. To open the app:

1. Click "Done" on the warning dialog
2. Open System Settings > Privacy & Security
3. Scroll down to find "QuickSnip.app was blocked"
4. Click "Open Anyway"
5. Confirm by clicking "Open" in the next dialog

This only needs to be done once.

### Granting Full Disk Access

After opening the app, grant Full Disk Access for Text Replacement sync:

1. Open System Settings > Privacy & Security > Full Disk Access
2. Click the + button
3. Navigate to /Applications and select QuickSnip
4. Restart QuickSnip

## How It Works

QuickSnip syncs your snippets to macOS Text Replacement by:

1. Writing to the system database (`~/Library/KeyboardServices/TextReplacements.db`)
2. Updating GlobalPreferences.plist for immediate local activation
3. Restarting the keyboard service daemon

When you delete a snippet, QuickSnip:
1. Marks the entry as deleted (`ZWASDELETED=1`) for iCloud sync propagation
2. Removes the entry from GlobalPreferences.plist for immediate local deactivation

This enables your snippets to sync to all your Apple devices via iCloud.

**Why this approach?** Apple provides no public API for Text Replacement. Alternatives like InputMethodKit don't sync to iOS. See the [Architecture Decision Record](QuickSnip/QuickSnip/Services/TextReplacementService.swift) for details.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

### Quick Start

```bash
# Clone
git clone https://github.com/pasogott/quicksnip-menubar-swift.git
cd quicksnip-menubar-swift

# Build
cd QuickSnip && xcodebuild -scheme QuickSnip -configuration Debug

# Test
xcodebuild test -scheme QuickSnip -destination 'platform=macOS'
```

### Project Structure

```
QuickSnip/
├── QuickSnipApp.swift          # @main, MenuBarExtra scene
├── Models/                     # Snippet, SnippetFolder, SyncStatus
├── Services/                   # File I/O, parsing, sync, variables
├── ViewModels/                 # SnippetTreeViewModel, SettingsViewModel
├── Views/                      # SwiftUI views
└── Resources/                  # Assets
```

## License

MIT
