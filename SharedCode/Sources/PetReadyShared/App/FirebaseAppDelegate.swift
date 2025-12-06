#if canImport(UIKit)
import UIKit
#if canImport(UserNotifications)
import UserNotifications
#endif
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

public final class FirebaseAppDelegate: NSObject, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppBootstrap.configureFirebaseIfNeeded()
#if canImport(UserNotifications)
        UNUserNotificationCenter.current().delegate = self
#endif
        application.registerForRemoteNotifications()
#if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
#endif
        return true
    }

#if canImport(FirebaseMessaging)
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
#endif
}

#if canImport(UserNotifications)
extension FirebaseAppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
#endif

#if canImport(FirebaseMessaging)
extension FirebaseAppDelegate: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // For future: send token to backend
    }
}
#endif
#endif
