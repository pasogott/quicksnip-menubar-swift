import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func showSuccess(title: String, message: String) {
        show(title: title, body: message, isCritical: false)
    }

    func showError(title: String, message: String) {
        show(title: title, body: message, isCritical: true)
    }

    // MARK: - Convenience Methods

    func showSyncSuccess(count: Int) {
        showSuccess(
            title: "Sync Complete",
            message: "Synced \(count) snippet\(count == 1 ? "" : "s") to Text Replacement"
        )
    }

    func showImportSuccess(count: Int) {
        showSuccess(
            title: "Import Complete",
            message: "Imported \(count) snippet\(count == 1 ? "" : "s")"
        )
    }

    // MARK: - Private

    private func show(title: String, body: String, isCritical: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = isCritical ? .defaultCritical : .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        center.add(request)
    }
}
