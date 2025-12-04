import Foundation

public enum PushPermissionState {
    case notDetermined
    case granted
    case denied
}

public protocol PushNotificationServiceProtocol: AnyObject {
    var permissionState: PushPermissionState { get }
    func requestPermission() async
    func registerDeviceToken(_ token: Data)
    func scheduleLocalNotification(title: String, body: String)
}

public final class PushNotificationService: PushNotificationServiceProtocol {
    public private(set) var permissionState: PushPermissionState = .notDetermined

    public init() {}

    public func requestPermission() async {
        // Placeholder: Wire to UNUserNotificationCenter later
        try? await Task.sleep(nanoseconds: 300_000_000)
        permissionState = .granted
    }

    public func registerDeviceToken(_ token: Data) {
        // Placeholder call; integration will happen when backend endpoints are ready
        print("[PushNotificationService] Registered token: \(token.base64EncodedString())")
    }

    public func scheduleLocalNotification(title: String, body: String) {
        // Placeholder only
        print("[PushNotificationService] Scheduling local notification: \(title) - \(body)")
    }
}
