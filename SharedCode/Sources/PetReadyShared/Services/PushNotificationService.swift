import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

public enum PushPermissionState {
    case notDetermined
    case granted
    case denied
}

public protocol PushNotificationServiceProtocol: AnyObject {
    var permissionState: PushPermissionState { get }
    func requestPermission() async
    func registerDeviceToken(_ token: Data)
    func scheduleLocalNotification(title: String, body: String, timeInterval: TimeInterval)
}

public final class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    public private(set) var permissionState: PushPermissionState = .notDetermined

    public func requestPermission() async {
#if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                permissionState = granted ? .granted : .denied
            }
        } catch {
            await MainActor.run {
                permissionState = .denied
            }
        }
#else
        permissionState = .denied
#endif
    }

    public func registerDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        print("[PushNotificationService] Registered token: \(tokenString)")
    }

    public func scheduleLocalNotification(title: String, body: String, timeInterval: TimeInterval = 1) {
#if canImport(UserNotifications)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, timeInterval), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[PushNotificationService] Failed to schedule notification: \(error)")
            }
        }
#else
        print("[PushNotificationService] Local notifications unavailable on this platform.")
#endif
    }
}
