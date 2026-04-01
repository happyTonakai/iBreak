import SwiftUI
import UserNotifications

@main
struct iBreakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var breakTimer = BreakTimer.shared
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var keyMonitor = GlobalKeyMonitor.shared
    private let breakWindowManager = BreakWindowManager()
    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        Window("iBreak Settings", id: "settings-window") {
            SettingsView()
                .environmentObject(settings)
        }
        .onChange(of: breakTimer.currentMode) { _, newMode in
            if newMode == .onShortBreak || newMode == .onLongBreak {
                keyMonitor.startMonitoring()
                breakWindowManager.showBreakWindows(with: breakTimer)
            } else {
                keyMonitor.stopMonitoring()
                breakWindowManager.hideBreakWindows()
            }
        }
    }
}
