import Foundation
import UserNotifications
import OSLog

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // This function is called when a notification is delivered to a foreground app.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Logger.log("Notification received while app is in foreground. Forcing it to display.", type: .info)
        // We tell the system to show the notification as a banner and play the default sound.
        completionHandler([.banner, .sound])
    }
}
