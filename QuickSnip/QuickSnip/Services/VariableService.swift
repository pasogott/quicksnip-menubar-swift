import Foundation
import AppKit

struct VariableService {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    static func expand(_ content: String) -> String {
        var result = content

        result = result.replacingOccurrences(
            of: "{date}",
            with: dateFormatter.string(from: Date())
        )

        result = result.replacingOccurrences(
            of: "{time}",
            with: timeFormatter.string(from: Date())
        )

        result = result.replacingOccurrences(
            of: "{clipboard}",
            with: clipboardContent()
        )

        return result
    }

    private static func clipboardContent() -> String {
        NSPasteboard.general.string(forType: .string) ?? ""
    }
}
