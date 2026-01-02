# Contributing to QuickSnip

## Development Setup

### Prerequisites

- macOS 15.0+ (Sequoia)
- Xcode 16.0+
- Swift 6.0+

### Getting Started

```bash
# Clone the repository
git clone https://github.com/pasogott/quicksnip-menubar-swift.git
cd quicksnip-menubar-swift

# Build
cd QuickSnip && xcodebuild -scheme QuickSnip -configuration Debug

# Run tests
xcodebuild test -scheme QuickSnip -destination 'platform=macOS'

# Run a single test
xcodebuild test -scheme QuickSnip -destination 'platform=macOS' \
  -only-testing:QuickSnipTests/TestClassName/testMethodName
```

## Issue Workflow

All changes must follow this workflow:

1. **Pick an issue** from the [issue tracker](https://github.com/pasogott/quicksnip-menubar-swift/issues)
2. **Assign yourself**: `gh issue edit <number> --add-assignee @me`
3. **Create a branch**: `git checkout -b feature/US-XXX-description` or `fix/XXX-description`
4. **Implement** the change
5. **Create a PR** targeting `development`: `gh pr create --base development`
6. **Merge** after CI passes: `gh pr merge <number> --squash --delete-branch`
7. **Update CHANGELOG.md** on the development branch

### Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production releases only |
| `development` | Integration branch, all PRs target this |
| `feature/US-XXX-*` | Feature branches from user stories |
| `fix/*` | Bug fix branches |

## Architecture

### Design Principles

- **Pure Swift** - Native macOS APIs only, no external dependencies
- **Files as source of truth** - Snippets are editable markdown files
- **Non-sandboxed** - Requires Full Disk Access for Text Replacement database
- **SOLID** - Protocol-based dependency injection throughout

### Project Structure

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
│   ├── SQLiteDatabase.swift        # SQLite wrapper
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

### Text Replacement Sync

QuickSnip writes directly to the macOS Text Replacement database. This is the only approach that enables iOS sync via iCloud. See the Architecture Decision Record in `TextReplacementService.swift` for details on why alternatives (InputMethodKit, Event Taps) were rejected.

**Sync process:**

1. Write to `~/Library/KeyboardServices/TextReplacements.db`
2. Update `.GlobalPreferences.plist` for immediate activation
3. Restart `keyboardservicesd` daemon

## Testing

### Running Tests

```bash
cd QuickSnip

# All tests
xcodebuild test -scheme QuickSnip -destination 'platform=macOS'

# Single test file
xcodebuild test -scheme QuickSnip -destination 'platform=macOS' \
  -only-testing:QuickSnipTests/MarkdownParserTests

# Single test method
xcodebuild test -scheme QuickSnip -destination 'platform=macOS' \
  -only-testing:QuickSnipTests/MarkdownParserTests/test_parse_extractsShortcut
```

### Test Structure

Tests mirror the source structure:

```
QuickSnipTests/
├── Models/
│   ├── SnippetTests.swift
│   └── SnippetFolderTests.swift
├── Services/
│   ├── MarkdownParserTests.swift
│   ├── SnippetFileServiceTests.swift
│   └── ImportExportServiceTests.swift
└── ViewModels/
    ├── SnippetTreeViewModelTests.swift
    └── SettingsViewModelTests.swift
```

### Writing Tests

- Use protocol-based mocks for dependencies
- Test one behavior per test method
- Name tests: `test_methodName_expectedBehavior`

## Code Style

### Swift

- Swift 6.0 with strict concurrency
- No force unwrapping in production code
- Use `guard` for early returns
- Prefer value types (structs) over reference types

### Git

- **Atomic commits** - One logical change per commit
- **No AI attribution** - Don't mention AI in commits or docs
- **Conventional format** - `Fix:`, `Add:`, `Update:`, `Remove:`

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

Required fields:
- `shortcut` - The trigger text (e.g., `;sig`)

Optional fields:
- `category` - For organization (default: filename)
- `enabled` - Whether to sync (default: true)

## GitHub Labels

| Label | Purpose |
|-------|---------|
| `user-story` | Feature implementation |
| `bug` | Bug reports |
| `epic:setup` | Epic 1: Project Setup |
| `epic:models` | Epic 2: Core Models |
| `epic:services` | Epic 3: File Services |
| `epic:text-replacement` | Epic 4: Text Replacement Integration |
| `epic:variables` | Epic 5: Variable Expansion |
| `epic:import-export` | Epic 6: Import/Export |
| `epic:viewmodels` | Epic 7: ViewModels |
| `epic:views` | Epic 8: UI Views |
| `epic:polish` | Epic 9: Polish |

## Questions?

Open an issue or check existing discussions.
