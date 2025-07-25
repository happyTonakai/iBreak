import SwiftUI
import AVFoundation
import ApplicationServices

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @StateObject private var launchManager = LaunchAtLoginManager()
    @State private var showingResetAlert = false
    @State private var settingsWindow: NSWindow?
    
    // Check and request accessibility permission if idle detection is enabled
    private func checkAndRequestAccessibilityPermissionIfNeeded() {
        // Only check if idle detection is enabled (threshold > 0)
        if settings.idleThreshold > 0 {
			Logger.log("Checking and requesting accessibility permission", type: .debug)
            if !AccessibilityPermissionManager.shared.hasPermission() {
                Logger.log("Accessibility permission not granted, requesting permission", type: .debug)
                AccessibilityPermissionManager.shared.requestPermission { granted in
                    if !granted {
                        // If permission was not granted, we might want to disable idle detection
                        // or show a warning to the user
                        // For now, we'll just log it
                        Logger.log("Accessibility permission not granted", type: .info)
                    }
                }
            }
			else {
				Logger.log("Accessibility permission already granted", type: .debug)
			}
        }
    }

    var body: some View {
        TabView {
            // MARK: - Timers Tab
            VStack {
                Form {
                    Section(header: Text("Focus Time").font(.headline)) {
                        CustomSlider(value: $settings.shortBreakInterval, steps: TimeIntervals.workIntervals, label: "Focus time before short break")
                        CustomSlider(value: $settings.longBreakInterval, steps: TimeIntervals.workIntervals, label: "Focus time before long break")
                    }
                    .padding(.bottom)
                    
                    Section(header: Text("Break Duration").font(.headline)) {
                        CustomSlider(value: $settings.shortBreakDuration, steps: TimeIntervals.smallBreakDurations, label: "Short break duration")
                        CustomSlider(value: $settings.longBreakDuration, steps: TimeIntervals.bigBreakDurations, label: "Long break duration")
                    }
                }
            }
            .tabItem {
                Label("Timers", systemImage: "timer")
            }
            .padding()

            // MARK: - Appearance Tab
            VStack(spacing: 20) {
                Form {
                    Section(header: Text("Break Theme").font(.headline)) {
                        ThemePickerView(selectedThemeName: $settings.themeName)
                    }
                    .padding(.bottom)
                    
                    Section(header: Text("Sound").font(.headline)) {
                        SoundPickerView(selectedSoundName: $settings.soundName)
                    }
                }
            }
            .tabItem {
                Label("Appearance", systemImage: "paintbrush")
            }
            .padding()

            // MARK: - Advanced Tab
            VStack {
                Form {
                    Section(header: Text("Behavior").font(.headline)) {
                        Toggle(isOn: $settings.showMenuBarIcon) { Text("Show icon in menu bar") }
                        Toggle(isOn: $settings.areNotificationsEnabled) { Text("Pre-break notifications") }
                        Toggle(isOn: $launchManager.isEnabled) { Text("Launch at Login") }
                        Toggle(isOn: $settings.isStrictModeEnabled) { Text("Strict Mode") }
                    }
                    .padding(.bottom)
                    
                    Section(header: Text("Idle Detection").font(.headline)) {
                        CustomSlider(value: $settings.idleThreshold, steps: TimeIntervals.idleThresholdIntervals, label: "Reset timer after inactivity")
                            .onAppear {
                                checkAndRequestAccessibilityPermissionIfNeeded()
                            }
                            .onChange(of: settings.idleThreshold) { _, _ in
                                checkAndRequestAccessibilityPermissionIfNeeded()
                            }
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button { showingResetAlert = true } label: { Text("Reset to Defaults") }
                    .padding(.top)
                }
            }
            .tabItem {
                Label("Advanced", systemImage: "gearshape")
            }
            .padding()
        }
        .frame(width: 400, height: 350)
        .background(WindowAccessor(window: $settingsWindow))
        .onChange(of: settingsWindow) { _, newWindow in
            if let window = newWindow {
                window.isRestorable = false
                window.setContentSize(NSSize(width: 450, height: 380))
            }
        }
        .alert(Text("Reset all settings to their default values?"), isPresented: $showingResetAlert) {
            Button { settings.resetToDefaults() } label: { Text("Reset") }
            Button(role: .cancel) { } label: { Text("Cancel") }
        }
        .onDisappear {
            settings.save()
        }
        .background(
            Button("") {
                if let window = settingsWindow {
                    window.close()
                }
                Logger.log("Esc pressed, close the setting window", type: .debug)
            }
            .keyboardShortcut(.escape, modifiers: [])
            .opacity(0)
        )
    }
}

// MARK: - Reusable Components

struct CustomSlider: View {
    @Binding var value: TimeInterval
    let steps: [TimeInterval]
    let label: LocalizedStringKey

    private var valueProxy: Binding<Double> {
        Binding<Double>(
            get: { Double(steps.firstIndex(of: value) ?? 0) },
            set: { newValue in
                let index = Int(round(newValue))
                if steps.indices.contains(index) {
                    value = steps[index]
                }
            }
        )
    }

    private func format(seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds)) sec"
        } else {
            return "\(Int(seconds / 60)) min"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            (Text(label) + Text(": \(format(seconds: value))"))
            Slider(value: valueProxy, in: 0...Double(steps.count - 1), step: 1)
        }
        .padding(.vertical, 4)
    }
}

struct ThemePickerView: View {
    @Binding var selectedThemeName: String

    var body: some View {
        HStack(spacing: 15) {
            ForEach(BreakTheme.allThemes) { theme in
                VStack(spacing: 8) {
                    Circle()
                        .fill(theme.backgroundColor)
                        .frame(width: 35, height: 35)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(selectedThemeName == theme.name ? 1 : 0.2), lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedThemeName = theme.name
                        }
                    Text(LocalizedStringKey(theme.name))
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct SoundPickerView: View {
    @Binding var selectedSoundName: String
    private let soundNames = NSSound.soundNames

    var body: some View {
        Picker(selection: $selectedSoundName) {
            ForEach(soundNames, id: \.self) { soundName in
                Text(soundName).tag(soundName)
            }
        } label: {
            Text("Notification Sound")
        }
        .onChange(of: selectedSoundName) { _, newSound in
            NSSound(named: newSound)?.play()
        }
    }
}
