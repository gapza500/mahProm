import Foundation
import UserNotifications

public final class ReminderService {
    public init() {}

    public func requestAuthorizationIfNeeded() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus != .authorized else { return }
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    public func schedule(reminder: Reminder) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Pet Reminder"
        content.body = "Action required for \(reminder.type)"

        let triggerDate = Calendar.current.dateComponents([
            .year, .month, .day, .hour, .minute
        ], from: reminder.fireDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}
