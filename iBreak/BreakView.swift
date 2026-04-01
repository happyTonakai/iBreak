import SwiftUI
import AVFoundation

struct BreakView: View {
    @EnvironmentObject var breakTimer: BreakTimer
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var settings = SettingsManager.shared
    
    @State private var currentMessage: String = ""

    private let breakMessages = [
        "Time to stretch!",
        "Look away from the screen for a bit.",
        "How about a glass of water?",
        "Take a few deep breaths.",
        "Close your eyes and relax.",
        "Stand up and walk around.",
        "Think about something you're grateful for."
    ]

    private var currentTheme: BreakTheme {
        return BreakTheme.theme(withName: settings.themeName)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            currentTheme.backgroundColor.edgesIgnoringSafeArea(.all)

            VStack {
                Text(LocalizedStringKey(breakTimer.currentMode.rawValue))
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(currentTheme.textColor)
                
                Text(currentMessage)
                    .font(.title)
                    .foregroundColor(currentTheme.textColor)
                    .padding(.top, 5)

                Text(breakTimer.timeRemainingFormatted)
                    .font(.system(size: 120, weight: .bold, design: .monospaced))
                    .foregroundColor(currentTheme.textColor)
                    .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !settings.isStrictModeEnabled && !settings.isForcedEndOfWorkModeEnabled {
                Button(action: {
                    breakTimer.skipBreak()
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
                .padding()
            }
        }
        .onAppear(perform: setupView)
        .onChange(of: breakTimer.currentMode) { _, newMode in
            if newMode == .working {
                dismiss()
            }
        }
    }

    private func setupView() {
        currentMessage = breakMessages.randomElement() ?? "Time for a break!"
        // Removed: NSSound(named: settings.soundName)?.play()
    }
}