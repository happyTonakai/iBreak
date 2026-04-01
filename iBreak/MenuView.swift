import SwiftUI
import OSLog

struct MenuView: View {
    @EnvironmentObject var breakTimer: BreakTimer
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let statusText = LocalizedStringKey(breakTimer.currentMode.rawValue)
            let nextBreakType: LocalizedStringKey = breakTimer.workCycle == 1 ? "Short Break" : "Long Break"
            
            (Text("Status:") + Text(" ") + Text(statusText) + (breakTimer.currentMode == .working ? Text(" - ") + Text(nextBreakType) : Text("")))
                .font(.headline)

            Divider()

            Button("Settings...") {
                Logger.log("MenuView: Settings button tapped.", type: .debug)
                openWindow(id: "settings-window")
            }

            Divider()

            if !breakTimer.isRunning && breakTimer.currentMode != .paused {
                 Button("Start Timer") {
                     Logger.log("MenuView: Start Timer button tapped.", type: .debug)
                     breakTimer.start(reset: true)
                 }
            }
            
            Button("Skip to Break") {
                Logger.log("MenuView: Skip to Break button tapped.", type: .debug)
                breakTimer.transitionToNextState()
            }
            
            Divider()
            
            Text("Pause for...").font(.caption).foregroundColor(.secondary)
            Button("30 minutes") {
                Logger.log("MenuView: Pause for 30 minutes tapped.", type: .debug)
                breakTimer.pause(for: .thirtyMinutes)
            }
            Button("1 hour") {
                Logger.log("MenuView: Pause for 1 hour tapped.", type: .debug)
                breakTimer.pause(for: .oneHour)
            }
            Button("2 hours") {
                Logger.log("MenuView: Pause for 2 hours tapped.", type: .debug)
                breakTimer.pause(for: .twoHours)
            }
            Button("Until tomorrow morning") {
                Logger.log("MenuView: Pause until tomorrow morning tapped.", type: .debug)
                breakTimer.pause(for: .untilMorning)
            }
            Button("Indefinitely") {
                Logger.log("MenuView: Pause indefinitely tapped.", type: .debug)
                breakTimer.pause(for: .indefinitely)
            }
            
            if breakTimer.currentMode == .paused {
                Divider()
                Button("Resume Timer") {
                    Logger.log("MenuView: Resume Timer button tapped.", type: .debug)
                    breakTimer.start(reset: false)
                }
            }

            Divider()

            // Display app version
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Quit iBreak") {
                Logger.log("MenuView: Quit iBreak button tapped.", type: .debug)
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}