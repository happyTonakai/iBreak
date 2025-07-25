import SwiftUI

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
                print("MenuView: Settings button tapped.")
                openWindow(id: "settings-window")
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            if !breakTimer.isRunning && breakTimer.currentMode != .paused {
                 Button("Start Timer") {
                     print("MenuView: Start Timer button tapped.")
                     breakTimer.start()
                 }
            }
            
            Button("Skip to Break") {
                print("MenuView: Skip to Break button tapped.")
                breakTimer.transitionToNextState()
            }
            
            Divider()
            
            Text("Pause for...").font(.caption).foregroundColor(.secondary)
            Button("30 minutes") {
                print("MenuView: Pause for 30 minutes tapped.")
                breakTimer.pause(for: .thirtyMinutes)
            }
            Button("1 hour") {
                print("MenuView: Pause for 1 hour tapped.")
                breakTimer.pause(for: .oneHour)
            }
            Button("2 hours") {
                print("MenuView: Pause for 2 hours tapped.")
                breakTimer.pause(for: .twoHours)
            }
            Button("Until tomorrow morning") {
                print("MenuView: Pause until tomorrow morning tapped.")
                breakTimer.pause(for: .untilMorning)
            }
            Button("Indefinitely") {
                print("MenuView: Pause indefinitely tapped.")
                breakTimer.pause(for: .indefinitely)
            }
            
            if breakTimer.currentMode == .paused {
                Divider()
                Button("Resume Timer") {
                    print("MenuView: Resume Timer button tapped.")
                    breakTimer.start()
                }
            }

            Divider()

            Button("Quit iBreak") {
                print("MenuView: Quit iBreak button tapped.")
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding()
    }
}