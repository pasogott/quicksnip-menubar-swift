import XCTest
@testable import QuickSnip

final class SnippetFolderTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_setsAllProperties() {
        let path = URL(fileURLWithPath: "/tmp/folder")
        let children = [
            SnippetFolder(name: "child", path: URL(fileURLWithPath: "/tmp/folder/child"))
        ]
        let snippets = [
            Snippet(shortcut: ";test", content: "Hello", filePath: URL(fileURLWithPath: "/tmp/test.md"))
        ]

        let folder = SnippetFolder(
            name: "folder",
            path: path,
            children: children,
            snippets: snippets
        )

        XCTAssertEqual(folder.name, "folder")
        XCTAssertEqual(folder.path, path)
        XCTAssertEqual(folder.children.count, 1)
        XCTAssertEqual(folder.snippets.count, 1)
    }

    func test_init_defaultsChildrenToEmpty() {
        let folder = SnippetFolder(
            name: "folder",
            path: URL(fileURLWithPath: "/tmp/folder")
        )

        XCTAssertTrue(folder.children.isEmpty)
    }

    func test_init_defaultsSnippetsToEmpty() {
        let folder = SnippetFolder(
            name: "folder",
            path: URL(fileURLWithPath: "/tmp/folder")
        )

        XCTAssertTrue(folder.snippets.isEmpty)
    }

    // MARK: - allSnippets Tests

    func test_allSnippets_returnsDirectSnippets() {
        let snippets = [
            Snippet(shortcut: ";a", content: "A", filePath: URL(fileURLWithPath: "/tmp/a.md")),
            Snippet(shortcut: ";b", content: "B", filePath: URL(fileURLWithPath: "/tmp/b.md"))
        ]

        let folder = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            snippets: snippets
        )

        XCTAssertEqual(folder.allSnippets.count, 2)
    }

    func test_allSnippets_includesNestedSnippets() {
        let childSnippets = [
            Snippet(shortcut: ";child", content: "Child", filePath: URL(fileURLWithPath: "/tmp/child/c.md"))
        ]
        let child = SnippetFolder(
            name: "child",
            path: URL(fileURLWithPath: "/tmp/child"),
            snippets: childSnippets
        )

        let rootSnippets = [
            Snippet(shortcut: ";root", content: "Root", filePath: URL(fileURLWithPath: "/tmp/r.md"))
        ]
        let root = SnippetFolder(
            name: "root",
            path: URL(fileURLWithPath: "/tmp"),
            children: [child],
            snippets: rootSnippets
        )

        XCTAssertEqual(root.allSnippets.count, 2)
    }

    func test_allSnippets_includesDeeplyNestedSnippets() {
        let deepSnippet = Snippet(shortcut: ";deep", content: "Deep", filePath: URL(fileURLWithPath: "/tmp/a/b/c/deep.md"))
        let level3 = SnippetFolder(name: "c", path: URL(fileURLWithPath: "/tmp/a/b/c"), snippets: [deepSnippet])
        let level2 = SnippetFolder(name: "b", path: URL(fileURLWithPath: "/tmp/a/b"), children: [level3])
        let level1 = SnippetFolder(name: "a", path: URL(fileURLWithPath: "/tmp/a"), children: [level2])
        let root = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"), children: [level1])

        XCTAssertEqual(root.allSnippets.count, 1)
        XCTAssertEqual(root.allSnippets.first?.shortcut, ";deep")
    }

    // MARK: - allFolders Tests

    func test_allFolders_includesSelf() {
        let folder = SnippetFolder(name: "folder", path: URL(fileURLWithPath: "/tmp"))

        XCTAssertEqual(folder.allFolders.count, 1)
        XCTAssertEqual(folder.allFolders.first?.name, "folder")
    }

    func test_allFolders_includesChildren() {
        let child = SnippetFolder(name: "child", path: URL(fileURLWithPath: "/tmp/child"))
        let root = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"), children: [child])

        XCTAssertEqual(root.allFolders.count, 2)
    }

    func test_allFolders_includesDeeplyNested() {
        let level3 = SnippetFolder(name: "c", path: URL(fileURLWithPath: "/tmp/a/b/c"))
        let level2 = SnippetFolder(name: "b", path: URL(fileURLWithPath: "/tmp/a/b"), children: [level3])
        let level1 = SnippetFolder(name: "a", path: URL(fileURLWithPath: "/tmp/a"), children: [level2])
        let root = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"), children: [level1])

        XCTAssertEqual(root.allFolders.count, 4)
    }

    // MARK: - snippetCount Tests

    func test_snippetCount_countsDirectSnippets() {
        let snippets = [
            Snippet(shortcut: ";a", content: "A", filePath: URL(fileURLWithPath: "/tmp/a.md")),
            Snippet(shortcut: ";b", content: "B", filePath: URL(fileURLWithPath: "/tmp/b.md")),
            Snippet(shortcut: ";c", content: "C", filePath: URL(fileURLWithPath: "/tmp/c.md"))
        ]

        let folder = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"), snippets: snippets)

        XCTAssertEqual(folder.snippetCount, 3)
    }

    func test_snippetCount_countsNestedSnippets() {
        let childSnippets = [
            Snippet(shortcut: ";c1", content: "C1", filePath: URL(fileURLWithPath: "/tmp/child/c1.md")),
            Snippet(shortcut: ";c2", content: "C2", filePath: URL(fileURLWithPath: "/tmp/child/c2.md"))
        ]
        let child = SnippetFolder(name: "child", path: URL(fileURLWithPath: "/tmp/child"), snippets: childSnippets)

        let rootSnippets = [
            Snippet(shortcut: ";r", content: "R", filePath: URL(fileURLWithPath: "/tmp/r.md"))
        ]
        let root = SnippetFolder(name: "root", path: URL(fileURLWithPath: "/tmp"), children: [child], snippets: rootSnippets)

        XCTAssertEqual(root.snippetCount, 3)
    }

    func test_snippetCount_returnsZeroForEmptyFolder() {
        let folder = SnippetFolder(name: "empty", path: URL(fileURLWithPath: "/tmp/empty"))

        XCTAssertEqual(folder.snippetCount, 0)
    }

    // MARK: - Equality Tests

    func test_equality_samePropertiesAreEqual() {
        let id = UUID()
        let path = URL(fileURLWithPath: "/tmp/folder")
        let folder1 = SnippetFolder(id: id, name: "folder", path: path)
        let folder2 = SnippetFolder(id: id, name: "folder", path: path)

        XCTAssertEqual(folder1, folder2)
    }

    func test_equality_differentIdAreNotEqual() {
        let folder1 = SnippetFolder(name: "folder", path: URL(fileURLWithPath: "/tmp"))
        let folder2 = SnippetFolder(name: "folder", path: URL(fileURLWithPath: "/tmp"))

        XCTAssertNotEqual(folder1, folder2)
    }
}
