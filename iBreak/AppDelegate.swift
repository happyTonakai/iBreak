import SwiftUI

// This class allows us to hook into application-level events, like termination.
class AppDelegate: NSObject, NSApplicationDelegate {
    // This function is automatically called by the system just before the app quits.
    func applicationWillTerminate(_ aNotification: Notification) {
        print("App is terminating. Cancelling all scheduled notifications.")
        // We simply call our existing cancel function.
        NotificationManager.shared.cancelNotifications()
    }
}
