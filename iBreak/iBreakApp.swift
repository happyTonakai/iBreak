import SwiftUI
import UserNotifications

@main
struct iBreakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var breakTimer = BreakTimer()
    @StateObject private var settings = SettingsManager.shared
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

        MenuBarExtra {
            MenuView()
                .environmentObject(breakTimer)
        } label: {
            if settings.showMenuBarIcon {
                if breakTimer.currentMode == .working {
                    // Check if the next break is a long break (workCycle will be 0).
                    let isLongBreakNext = breakTimer.workCycle == 0
                    let timerText = breakTimer.timeRemainingFormatted + (isLongBreakNext ? "•" : "")
                    Text(timerText)
                } else {
                    Image(systemName: "cup.and.saucer.fill")
                }
            } else {
                EmptyView()
            }
        }
        .menuBarExtraStyle(.menu)
        .onChange(of: breakTimer.currentMode) { _, newMode in
            if newMode == .onShortBreak || newMode == .onLongBreak {
                breakWindowManager.showBreakWindows(with: breakTimer)
            } else {
                breakWindowManager.hideBreakWindows()
            }
        }
    }
}
