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

## Phase 1: User Experience Polish

### 1.1 Editor Integration
- [ ] Open snippet in default markdown editor on double-click
- [ ] Quick edit modal within the app
- [ ] Syntax highlighting in preview

### 1.2 Search Improvements
- [ ] Fuzzy search across shortcuts and content
- [ ] Search history
- [ ] Filter by category/folder

### 1.3 Keyboard Navigation
- [ ] Arrow keys to navigate snippet list
- [ ] Enter to copy selected snippet
- [ ] Global hotkey to open menubar popover

---

## Phase 2: Advanced Variables

### 2.1 New Variable Types
- [ ] `{cursor}` - cursor position after paste
- [ ] `{selected}` - currently selected text
- [ ] `{input:prompt}` - prompt user for input
- [ ] `{random:list}` - random selection from list

### 2.2 Date/Time Formatting
- [ ] `{date:YYYY-MM-DD}` - custom date format
- [ ] `{time:HH:mm}` - custom time format
- [ ] `{datetime:ISO}` - ISO 8601 format

### 2.3 Transformations
- [ ] `{clipboard:uppercase}` - text transformations
- [ ] `{clipboard:lowercase}`
- [ ] `{clipboard:trim}`

---

## Phase 3: Sync & Backup

### 3.1 iCloud Drive Sync
- [ ] Option to store snippets in iCloud Drive
- [ ] Conflict resolution for simultaneous edits
- [ ] Offline support with sync on reconnect

### 3.2 Git Integration
- [ ] Auto-commit changes to snippets repo
- [ ] Push/pull from remote
- [ ] Version history viewer

### 3.3 Backup & Restore
- [ ] Scheduled automatic backups
- [ ] Restore from backup UI
- [ ] Export all settings and snippets

---

## Phase 4: Collaboration

### 4.1 Team Sharing
- [ ] Shared snippet folders via file sharing
- [ ] Read-only vs. editable permissions
- [ ] Merge imported snippets intelligently

### 4.2 Templates
- [ ] Snippet templates for common use cases
- [ ] Community template library (optional)
- [ ] Template variables for customization

---

## Phase 5: Platform Expansion

### 5.1 iOS Companion App
- [ ] View and copy snippets on iOS
- [ ] iCloud sync between macOS and iOS app
- [ ] Spotlight search integration

### 5.2 Alfred/Raycast Integration
- [ ] Alfred workflow for snippet search
- [ ] Raycast extension
- [ ] Keyboard Maestro plugin

---

## Phase 6: Developer Features

### 6.1 Scripting Support
- [ ] Shell script snippets with execution
- [ ] AppleScript integration
- [ ] JavaScript snippet evaluation

### 6.2 API & Automation
- [ ] Local HTTP API for snippet access
- [ ] CLI tool for terminal access
- [ ] Shortcuts app integration

---

## Phase 7: Distribution & Trust

### 7.1 Code Signing
- [ ] Apple Developer certificate
- [ ] Notarization for Gatekeeper
- [ ] Automatic update mechanism

### 7.2 App Store
- [ ] Sandboxed version with limited features
- [ ] App Store listing
- [ ] In-app purchase for pro features (optional)

---

## Backlog (Community Requests)

Items to consider based on user feedback:
- [ ] Snippet statistics (usage count, last used)
- [ ] Dark/light mode toggle
- [ ] Custom menubar icon
- [ ] Snippet expiration dates
- [ ] Encrypted snippets
- [ ] Multi-language snippet variants

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to QuickSnip.

To propose a new feature:
1. Open a GitHub issue with the `enhancement` label
2. Describe the use case and expected behavior
3. Discuss implementation approach

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| 1.0.4 | 2026-01-02 | Social preview, workflow fixes |
| 1.0.2 | 2026-01-02 | Concurrency crash fix |
| 1.0.1 | 2026-01-02 | iCloud sync fix, FDA detection |
| 1.0.0 | 2026-01-01 | Initial release |
