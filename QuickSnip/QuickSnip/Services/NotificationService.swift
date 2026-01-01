import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func showSyncSuccess(count: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Sync Complete"
        content.body = "Synced \(count) snippet\(count == 1 ? "" : "s") to Text Replacement"
        content.sound = .default

        scheduleNotification(content: content, identifier: "sync-success")
    }

    func showImportSuccess(count: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Import Complete"
        content.body = "Imported \(count) snippet\(count == 1 ? "" : "s")"
        content.sound = .default

        scheduleNotification(content: content, identifier: "import-success")
    }

    func showError(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .defaultCritical

        scheduleNotification(content: content, identifier: "error-\(UUID().uuidString)")
    }

    private func scheduleNotification(content: UNMutableNotificationContent, identifier: String) {
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
