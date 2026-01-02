# QuickSnip Roadmap

## Current State: v1.0.4 (Production Ready)

QuickSnip is a fully functional macOS menubar app with:
- Markdown-based snippet storage in `~/.snippets/`
- Text Replacement sync to macOS and iOS via iCloud
- Variable expansion: `{date}`, `{time}`, `{clipboard}`
- Import/export as zip archives
- Live file watching with auto-reload
- 150 tests with 93% test coverage

---

## v1.1: Quick Wins

### 1.1.1 Settings & Configuration
- [ ] Version display in Settings window
- [ ] Configurable snippets folder (default: `~/.snippets/`)
- [ ] Folder picker with validation

### 1.1.2 Snippet Management
- [ ] Snippet statistics: usage count, last used timestamp
- [ ] Duplicate shortcut detection with warning
- [ ] Sortierung: by name, date, usage frequency
- [ ] Recent snippets quick-access list (last 5 used)

### 1.1.3 Sync Improvements
- [ ] 2-way sync: Text Replacement changes back to snippet files
- [ ] Conflict detection and resolution UI
- [ ] Sync status per snippet (in sync, local only, conflict)

---

## v1.2: Shell Variables & Documentation

### 1.2.1 Shell Command Variables
- [ ] `{shell:command}` - execute shell command and insert output
- [ ] `{env:VAR}` - environment variable expansion
- [ ] Examples:
  - `{shell:date +%Y-%m-%d}` - formatted date via shell
  - `{shell:whoami}` - current username
  - `{shell:git branch --show-current}` - current git branch
  - `{env:HOME}` - home directory

### 1.2.2 Variable Documentation
- [ ] In-app variable reference (accessible from Settings)
- [ ] Variable syntax help in snippet editor
- [ ] Example snippets with common variable patterns
- [ ] Error messages for invalid variable syntax

### 1.2.3 Extended Built-in Variables
- [ ] `{date:FORMAT}` - custom date format (strftime compatible)
- [ ] `{time:FORMAT}` - custom time format
- [ ] `{clipboard:transform}` - uppercase, lowercase, trim
- [ ] `{uuid}` - generate UUID
- [ ] `{random:min-max}` - random number in range

---

## v1.3: UX Improvements

### 1.3.1 Drag & Drop
- [ ] Drag snippets between folders
- [ ] Drag to reorder within folder
- [ ] Drop files to import as snippets

### 1.3.2 Inline Editing
- [ ] Edit snippet content directly in menubar
- [ ] Edit shortcut inline
- [ ] Quick toggle enabled/disabled

### 1.3.3 Favorites & Organization
- [ ] Star/favorite snippets
- [ ] Favorites section at top of list
- [ ] Color-coded categories
- [ ] Snippet tags (additional to folders)

### 1.3.4 Keyboard & Navigation
- [ ] Global hotkey to open menubar (configurable)
- [ ] Arrow keys to navigate list
- [ ] Enter to copy, Cmd+Enter to edit
- [ ] Type to filter (instant search)

---

## v1.4: Integrations

### 1.4.1 URL Scheme
- [ ] `quicksnip://copy?shortcut=;sig` - copy snippet
- [ ] `quicksnip://open` - open menubar
- [ ] `quicksnip://sync` - trigger sync
- [ ] `quicksnip://new?content=...` - create snippet

### 1.4.2 Shortcuts.app
- [ ] "Copy Snippet" action
- [ ] "List Snippets" action
- [ ] "Create Snippet" action
- [ ] "Sync Snippets" action

### 1.4.3 Third-Party Tools
- [ ] Alfred workflow
- [ ] Raycast extension
- [ ] AppleScript dictionary
- [ ] Spotlight indexing for snippets

---

## Future Phases

### Phase 5: Platform Expansion
- iOS Companion App with iCloud sync
- Spotlight search integration

### Phase 6: Developer Features
- Shell script snippets with execution
- Local HTTP API for automation
- CLI tool for terminal access

### Phase 7: Distribution
- Apple Developer certificate & notarization
- Automatic update mechanism (Sparkle)
- Optional App Store version

---

## Backlog

Items for future consideration:
- [ ] Encrypted/password-protected snippets
- [ ] Snippet expiration dates (auto-disable)
- [ ] Multi-language snippet variants
- [ ] Team sharing via shared folders
- [ ] Git integration for version history
- [ ] Snippet templates library

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.

To propose a feature:
1. Open a GitHub issue with the `enhancement` label
2. Describe use case and expected behavior
3. Discuss implementation approach

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| 1.0.4 | 2026-01-02 | Social preview, workflow fixes |
| 1.0.2 | 2026-01-02 | Concurrency crash fix |
| 1.0.1 | 2026-01-02 | iCloud sync fix, FDA detection |
| 1.0.0 | 2026-01-01 | Initial release |
