# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuickSnip is a native macOS menubar app for managing text snippets. Snippets are stored as markdown files with YAML frontmatter in `~/.snippets/`. The app syncs snippets to macOS native Text Replacement (which syncs to iOS via iCloud).

## Build Commands

```bash
# Build
cd QuickSnip && xcodebuild -scheme QuickSnip -configuration Release

# Build for debugging
cd QuickSnip && xcodebuild -scheme QuickSnip -configuration Debug

# Run tests
cd QuickSnip && xcodebuild test -scheme QuickSnip -destination 'platform=macOS'
```

## Architecture

**Design Principles:**
- Pure Swift with native macOS APIs only (no external dependencies)
- Files as source of truth: snippets are editable markdown files
- Non-sandboxed: requires Full Disk Access for Text Replacement database

**Data Flow:**
```
QuickSnipApp (MenuBarExtra)
    └── SnippetTreeViewModel (main state)
            ├── SnippetFileService      → ~/.snippets/*.md
            ├── FileWatcherService      → FSEvents for live reload
            ├── TextReplacementService  → ~/Library/KeyboardServices/TextReplacements.db
            ├── VariableService         → expands {date}, {time}, {clipboard}
            └── ImportExportService     → .zip import/export
```

**Key Technical Decisions:**
- Direct SQLite access to `~/Library/KeyboardServices/TextReplacements.db` for Text Replacement sync (no public API exists)
- FSEvents for recursive file system monitoring with 0.5s debounce
- YAML frontmatter format (`---` delimited) for snippet metadata

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

## Requirements

- macOS 15.0+ (Sequoia)
- Xcode 16.0+
- Swift 6.0+
- Full Disk Access permission for Text Replacement sync

## Info.plist Configuration

- `LSUIElement: true` - menubar only, no dock icon
- App Sandbox disabled for database and file access
