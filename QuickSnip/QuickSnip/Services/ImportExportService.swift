import Foundation

struct ImportExportService {
    private let fileManager = FileManager.default
    private let snippetsDirectory: URL

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        snippetsDirectory = home.appendingPathComponent(".snippets", isDirectory: true)
    }

    func exportToZip(folder: SnippetFolder, destination: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-c", "-k", "--keepParent", folder.path.path, destination.path]

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ImportExportError.exportFailed
        }
    }

    func importFromZip(_ zipURL: URL) throws -> ImportResult {
        let tempDirectory = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDirectory) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-x", "-k", zipURL.path, tempDirectory.path]

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ImportExportError.invalidZipFile
        }

        let contents = try fileManager.contentsOfDirectory(
            at: tempDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        var imported = 0
        var skipped = 0

        for item in contents {
            let result = try importItem(item, to: snippetsDirectory)
            imported += result.imported
            skipped += result.skipped
        }

        return ImportResult(imported: imported, skipped: skipped)
    }

    func importFolder(_ folderURL: URL) throws -> ImportResult {
        return try importItem(folderURL, to: snippetsDirectory)
    }

    private func importItem(_ source: URL, to destination: URL) throws -> ImportResult {
        let resourceValues = try source.resourceValues(forKeys: [.isDirectoryKey])
        let isDirectory = resourceValues.isDirectory ?? false

        let targetURL = uniqueURL(for: source.lastPathComponent, in: destination)

        if isDirectory {
            try fileManager.copyItem(at: source, to: targetURL)
            let count = try countMarkdownFiles(in: targetURL)
            return ImportResult(imported: count, skipped: 0)
        } else if source.pathExtension == "md" {
            try fileManager.copyItem(at: source, to: targetURL)
            return ImportResult(imported: 1, skipped: 0)
        } else {
            return ImportResult(imported: 0, skipped: 1)
        }
    }

    private func uniqueURL(for name: String, in directory: URL) -> URL {
        var targetURL = directory.appendingPathComponent(name)

        if !fileManager.fileExists(atPath: targetURL.path) {
            return targetURL
        }

        let baseName = targetURL.deletingPathExtension().lastPathComponent
        let ext = targetURL.pathExtension

        var counter = 1
        while fileManager.fileExists(atPath: targetURL.path) {
            let newName = ext.isEmpty ? "\(baseName)-\(counter)" : "\(baseName)-\(counter).\(ext)"
            targetURL = directory.appendingPathComponent(newName)
            counter += 1
        }

        return targetURL
    }

    private func countMarkdownFiles(in directory: URL) throws -> Int {
        let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        var count = 0
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.pathExtension == "md" {
                count += 1
            }
        }
        return count
    }
}

struct ImportResult {
    let imported: Int
    let skipped: Int

    var description: String {
        if imported == 0 && skipped == 0 {
            return "No files to import"
        }
        var parts: [String] = []
        if imported > 0 {
            parts.append("\(imported) imported")
        }
        if skipped > 0 {
            parts.append("\(skipped) skipped")
        }
        return parts.joined(separator: ", ")
    }
}

enum ImportExportError: LocalizedError {
    case exportFailed
    case invalidZipFile
    case importFailed

    var errorDescription: String? {
        switch self {
        case .exportFailed:
            return "Failed to create zip archive"
        case .invalidZipFile:
            return "Invalid or corrupted zip file"
        case .importFailed:
            return "Failed to import files"
        }
    }
}
