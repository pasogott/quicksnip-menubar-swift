# QuickSnip

A native macOS menubar app for managing text snippets with macOS Text Replacement sync.

## Installation

### Homebrew (recommended)

```bash
brew tap pasogott/tap
brew install --cask quicksnip
```

### Manual Download

Download the latest DMG from [Releases](https://github.com/pasogott/quicksnip-menubar-swift/releases).

## Overview

QuickSnip stores snippets as markdown files with YAML frontmatter in `~/.snippets/`. It provides a hierarchical tree view, file watching for external edits, import/export for sharing, and integration with macOS native Text Replacement.

## Features

- **Menubar Tree View** - Recursive folder/snippet hierarchy
- **File Watcher** - Auto-reload on external edits
- **Text Replacement Sync** - Import to macOS native system (syncs to iOS via iCloud)
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

## Development

### Prerequisites

- Xcode 16.0+
- Swift 6.0+

### Building

```bash
cd QuickSnip
xcodebuild -scheme QuickSnip -configuration Release
```

### Project Structure

```
QuickSnip/
├── QuickSnipApp.swift
├── Models/
├── Services/
├── ViewModels/
├── Views/
└── Resources/
```

## License

MIT
