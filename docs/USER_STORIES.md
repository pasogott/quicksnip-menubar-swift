# QuickSnip User Stories

## Epic 1: Project Setup

### US-001: Initialize Xcode Project
**As a** developer
**I want** a properly configured Xcode project
**So that** I can build and run the app

**Acceptance Criteria:**
- [ ] Xcode project created with SwiftUI lifecycle
- [ ] Bundle ID: `com.quicksnip.app`
- [ ] Deployment target: macOS 15.0
- [ ] LSUIElement = true (no dock icon)
- [ ] App Sandbox disabled
- [ ] Folder structure matches architecture

---

### US-002: Set Up GitHub Actions CI/CD
**As a** developer
**I want** automated builds and tests
**So that** code quality is maintained

**Acceptance Criteria:**
- [ ] Build workflow on push to any branch
- [ ] Test workflow on pull request
- [ ] Release workflow on tag push
- [ ] macOS runner with Xcode 16

---

## Epic 2: Core Models

### US-003: Implement Snippet Model
**As a** developer
**I want** a Snippet data model
**So that** snippets can be represented in memory

**Acceptance Criteria:**
- [ ] Properties: id, shortcut, content, category, enabled, filePath, fileName, lastModified
- [ ] Identifiable, Codable, Hashable conformance
- [ ] Initializer from file URL

---

### US-004: Implement SnippetFolder Model
**As a** developer
**I want** a SnippetFolder tree node model
**So that** folder hierarchy can be represented

**Acceptance Criteria:**
- [ ] Properties: id, name, path, children, snippets, isExpanded, parent
- [ ] ObservableObject for SwiftUI binding
- [ ] Computed property for allSnippets (recursive)

---

### US-005: Implement SyncStatus Enum
**As a** developer
**I want** sync status representation
**So that** UI can show current state

**Acceptance Criteria:**
- [ ] Cases: idle, syncing, synced, error(String)
- [ ] Computed property for SF Symbol name
- [ ] Equatable conformance

---

## Epic 3: File Services

### US-006: Implement MarkdownParser
**As a** developer
**I want** to parse YAML frontmatter from markdown files
**So that** snippet metadata can be extracted

**Acceptance Criteria:**
- [ ] Parse `---` delimited frontmatter
- [ ] Extract shortcut (required), category (optional), enabled (default true)
- [ ] Return content after frontmatter
- [ ] Handle malformed files gracefully

---

### US-007: Implement SnippetFileService
**As a** developer
**I want** file I/O operations for snippets
**So that** snippets can be loaded from disk

**Acceptance Criteria:**
- [ ] Create ~/.snippets/ if not exists
- [ ] Load snippet tree recursively
- [ ] Create new snippet file with template
- [ ] Create new folder
- [ ] Sort folders and snippets alphabetically

---

### US-008: Implement FileWatcherService
**As a** developer
**I want** to watch for file changes
**So that** the app updates when files are edited externally

**Acceptance Criteria:**
- [ ] Use FSEvents for recursive monitoring
- [ ] Debounce callbacks (0.5s)
- [ ] Start/stop methods
- [ ] Delegate callback on changes

---

## Epic 4: Text Replacement Integration

### US-009: Implement SQLite Wrapper
**As a** developer
**I want** a simple SQLite interface
**So that** I can access the Text Replacement database

**Acceptance Criteria:**
- [ ] Open/close database
- [ ] Execute raw SQL
- [ ] Query with results
- [ ] Proper error handling

---

### US-010: Implement TextReplacementService
**As a** developer
**I want** to sync snippets to macOS Text Replacement
**So that** snippets work system-wide

**Acceptance Criteria:**
- [ ] Check database access (hasAccess property)
- [ ] Get current replacements
- [ ] Sync snippets (insert/update)
- [ ] Prompt for Full Disk Access
- [ ] Handle restart requirement

---

## Epic 5: Variable Expansion

### US-011: Implement VariableService
**As a** developer
**I want** to expand variables in snippet content
**So that** dynamic content works when copying

**Acceptance Criteria:**
- [ ] Expand {date} to formatted date
- [ ] Expand {time} to formatted time
- [ ] Expand {clipboard} to clipboard contents
- [ ] Leave unknown variables unchanged

---

## Epic 6: Import/Export

### US-012: Implement ImportExportService
**As a** developer
**I want** to import and export snippets
**So that** users can share with teammates

**Acceptance Criteria:**
- [ ] Export folder to .zip using ditto
- [ ] Import .zip to ~/.snippets/
- [ ] Import folder (copy)
- [ ] Handle name conflicts

---

## Epic 7: ViewModels

### US-013: Implement SnippetTreeViewModel
**As a** developer
**I want** main app state management
**So that** views can react to state changes

**Acceptance Criteria:**
- [ ] Published: rootFolder, syncStatus, searchText, errorMessage
- [ ] Methods: loadSnippets, syncToTextReplacement, copyToClipboard
- [ ] Methods: createNewSnippet, createNewFolder, openSnippetsFolder
- [ ] File watcher integration
- [ ] Search filtering

---

### US-014: Implement SettingsViewModel
**As a** developer
**I want** settings state management
**So that** preferences can be persisted

**Acceptance Criteria:**
- [ ] Launch at login toggle (SMAppService)
- [ ] Auto-sync toggle
- [ ] Persist to UserDefaults

---

## Epic 8: UI Views

### US-015: Implement QuickSnipApp Entry Point
**As a** developer
**I want** the app entry point with MenuBarExtra
**So that** the app runs as a menubar app

**Acceptance Criteria:**
- [ ] @main struct with App protocol
- [ ] MenuBarExtra with .window style
- [ ] Settings scene for preferences window

---

### US-016: Implement MenuBarContentView
**As a** developer
**I want** the main menubar popover content
**So that** users can interact with snippets

**Acceptance Criteria:**
- [ ] Header with app name and status
- [ ] Search field
- [ ] Scrollable snippet tree
- [ ] Action buttons (New, Open Folder, Sync, Import, Export)
- [ ] Settings and Quit buttons

---

### US-017: Implement SnippetTreeView
**As a** developer
**I want** a recursive tree view
**So that** folder hierarchy is displayed

**Acceptance Criteria:**
- [ ] Render folders with disclosure
- [ ] Render snippets
- [ ] Support search filtering
- [ ] Recursive for nested folders

---

### US-018: Implement SnippetRowView
**As a** developer
**I want** a snippet row component
**So that** individual snippets can be displayed and interacted with

**Acceptance Criteria:**
- [ ] Show filename and shortcut
- [ ] Show enabled/disabled state
- [ ] Click to copy
- [ ] Long press to preview
- [ ] Hover actions (copy, edit)

---

### US-019: Implement FolderRowView
**As a** developer
**I want** a folder row component
**So that** folders can be expanded/collapsed

**Acceptance Criteria:**
- [ ] Disclosure indicator
- [ ] Folder icon
- [ ] Folder name
- [ ] Snippet count badge
- [ ] Click to toggle expansion

---

### US-020: Implement SnippetPreviewView
**As a** developer
**I want** a snippet preview popover
**So that** users can see full content on long press

**Acceptance Criteria:**
- [ ] Show full snippet content
- [ ] Show shortcut
- [ ] Copy button
- [ ] Edit button
- [ ] Dismiss on click outside

---

### US-021: Implement SettingsWindowView
**As a** developer
**I want** a settings window
**So that** users can configure the app

**Acceptance Criteria:**
- [ ] General section (launch at login, auto-sync)
- [ ] Text Replacement section (access status, grant button)
- [ ] About section (version)

---

## Epic 9: Polish

### US-022: Add App Icons
**As a** user
**I want** a recognizable app icon
**So that** I can identify the app

**Acceptance Criteria:**
- [ ] Menubar icon (template image)
- [ ] App icon for About/Settings

---

### US-023: Add Keyboard Shortcuts
**As a** user
**I want** keyboard shortcuts
**So that** I can use the app efficiently

**Acceptance Criteria:**
- [ ] Cmd+N for new snippet
- [ ] Cmd+Shift+N for new folder
- [ ] Cmd+R for sync
- [ ] Cmd+, for settings

---

### US-024: Add Notifications
**As a** user
**I want** notifications
**So that** I know when actions complete

**Acceptance Criteria:**
- [ ] Notification on successful sync
- [ ] Notification on import complete
- [ ] Error notifications
