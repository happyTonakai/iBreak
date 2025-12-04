import SwiftUI
import OSLog

// This class allows us to hook into application-level events, like termination.
class AppDelegate: NSObject, NSApplicationDelegate {
    private var screenLockObserver: ScreenLockObserver?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        screenLockObserver = ScreenLockObserver()
        
        // Hide the app icon from the dock
        NSApp.setActivationPolicy(.accessory)
        Logger.log("App activation policy set to accessory (hidden from dock)", type: .info)
    }
    
    // This function is automatically called by the system just before the app quits.
    func applicationWillTerminate(_ aNotification: Notification) {
        Logger.log("App is terminating. Cancelling all scheduled notifications.", type: .info)
        // We simply call our existing cancel function.
        NotificationManager.shared.cancelNotifications()
    }
}
