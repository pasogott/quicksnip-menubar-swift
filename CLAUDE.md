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

# Run single test
cd QuickSnip && xcodebuild test -scheme QuickSnip -destination 'platform=macOS' -only-testing:QuickSnipTests/TestClassName/testMethodName
```

## Development Workflow

### Issue Workflow (Mandatory)

Always follow this workflow for every issue:

1. **Assign issue** - `gh issue edit <number> --add-assignee @me`
2. **Create branch** - `git checkout -b feature/US-XXX-description`
3. **Implement** - Write code, build, verify
4. **Update docs** - Update relevant documentation if needed
5. **Create PR** - `gh pr create --base development`
6. **Merge PR** - `gh pr merge <number> --squash --delete-branch`
7. **Update CHANGELOG** - Add entry on development branch

### Working on an Issue

1. **Pick up an issue**
   ```bash
   # List open issues
   gh issue list --state open

   # View issue details
   gh issue view <issue-number>

   # Assign yourself
   gh issue edit <issue-number> --add-assignee @me
   ```

2. **Create a feature branch**
   ```bash
   # Branch naming: feature/US-XXX-short-description or fix/issue-number-description
   git checkout development
   git pull origin development
   git checkout -b feature/US-001-init-xcode-project
   ```

3. **Implement and build**
   ```bash
   cd QuickSnip && xcodebuild -scheme QuickSnip -configuration Debug
   ```

4. **Create a PR to development**
   ```bash
   git push -u origin feature/US-001-init-xcode-project
   gh pr create --base development --title "[US-001] Initialize Xcode Project" --body "Closes #<issue-number>"
   ```

5. **Merge PR and update changelog**
   ```bash
   gh pr merge <pr-number> --squash --delete-branch
   git checkout development && git pull
   # Update CHANGELOG.md with the changes
   ```

### Branch Strategy

- `main` - production releases only
- `development` - integration branch, all PRs target this
- `feature/US-XXX-*` - feature branches from user stories
- `fix/*` - bug fix branches

### PR Requirements

- All PRs must target `development`
- CI must pass (build + tests)
- Link the issue in the PR body with `Closes #<issue-number>`

## Architecture

**Design Principles:**
- Pure Swift with native macOS APIs only (no external dependencies)
- Files as source of truth: snippets are editable markdown files
- Non-sandboxed: requires Full Disk Access for Text Replacement database

**Data Flow:**
```
QuickSnip/
├── QuickSnipApp.swift              # @main, MenuBarExtra scene
├── Models/
│   ├── Snippet.swift               # Snippet data model
│   ├── SnippetFolder.swift         # Folder tree node
│   └── SyncStatus.swift            # Sync state enum
├── Services/
│   ├── SnippetFileService.swift    # File I/O, tree loading
│   ├── MarkdownParser.swift        # YAML frontmatter extraction
│   ├── FileWatcherService.swift    # FSEvents for live reload
│   ├── TextReplacementService.swift # SQLite sync to macOS
│   ├── VariableService.swift       # {date}, {time}, {clipboard}
│   └── ImportExportService.swift   # Zip import/export
├── ViewModels/
│   ├── SnippetTreeViewModel.swift  # Main app state
│   └── SettingsViewModel.swift     # Settings state
└── Views/
    ├── MenuBarContentView.swift    # Main popover
    ├── SnippetTreeView.swift       # Recursive tree
    ├── SnippetRowView.swift        # Snippet row
    ├── FolderRowView.swift         # Folder row
    ├── SnippetPreviewView.swift    # Long-press preview
    └── SettingsWindowView.swift    # Settings window
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

## GitHub Labels

- `user-story` - feature implementation
- `bug` - bug reports
- `epic:setup` - Epic 1: Project Setup
- `epic:models` - Epic 2: Core Models
- `epic:services` - Epic 3: File Services
- `epic:text-replacement` - Epic 4: Text Replacement Integration
- `epic:variables` - Epic 5: Variable Expansion
- `epic:import-export` - Epic 6: Import/Export
- `epic:viewmodels` - Epic 7: ViewModels
- `epic:views` - Epic 8: UI Views
- `epic:polish` - Epic 9: Polish
