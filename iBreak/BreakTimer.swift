import Foundation
import Combine
import SwiftUI
import AVFoundation // Import AVFoundation for NSSound

enum TimerMode: String {
    case working, onShortBreak, onLongBreak, paused
}

enum PauseDuration: TimeInterval {
    case thirtyMinutes = 1800, oneHour = 3600, twoHours = 7200, untilMorning = -1, indefinitely = -2
}

class BreakTimer: ObservableObject {
    @Published var timeRemainingFormatted: String = "00:00"
    @Published var isRunning = false
    @Published var currentMode: TimerMode = .working
    @Published var targetDate: Date?

    private let settings = SettingsManager.shared
    var workCycle = 0
    private var idleMonitor = IdleTimeMonitor()
    private var timer: AnyCancellable?
    private var pausedUntil: Date?

    init() {
        print("BreakTimer: init() called.")
        start()
    }

    func start() {
        print("BreakTimer: start() called. isRunning: \(isRunning), currentMode: \(currentMode)")
        NotificationManager.shared.cancelNotifications() // Clear any old notifications
        
        // No guard here. Always attempt to start/resume.
        isRunning = true
        pausedUntil = nil
        
        // If we were paused, or just starting, set to working mode and start a new work interval.
        if currentMode == .paused || targetDate == nil {
            currentMode = .working
            startNextWorkInterval()
        }
        startInternalTimer()
        print("BreakTimer: start() finished. isRunning: \(isRunning), currentMode: \(currentMode)")
    }

    func stop() {
        print("BreakTimer: stop() called. isRunning: \(isRunning), currentMode: \(currentMode)")
        isRunning = false
        targetDate = nil
        timer?.cancel()
        // When stopped, explicitly set mode to working, ready for a fresh start.
        currentMode = .working
        print("BreakTimer: stop() finished.")
    }
    
    func pause(for duration: PauseDuration) {
        print("BreakTimer: pause(for: \(duration)) called. currentMode: \(currentMode)")
        NotificationManager.shared.cancelNotifications()
        stop()
        currentMode = .paused
        targetDate = nil
        switch duration {
        case .thirtyMinutes, .oneHour, .twoHours:
            pausedUntil = Date().addingTimeInterval(duration.rawValue)
            startInternalTimer() // Resume checking for unpause time
        case .untilMorning:
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.day! += 1; components.hour = 8; components.minute = 0
            pausedUntil = Calendar.current.date(from: components)
            startInternalTimer() // Resume checking for unpause time
        case .indefinitely:
            pausedUntil = nil // No resume time
        }
        print("BreakTimer: pause() finished. currentMode: \(currentMode)")
    }

    func transitionToNextState() {
        print("BreakTimer: transitionToNextState() called. currentMode: \(currentMode)")
        let previousMode = currentMode // Capture current mode before changing
        switch currentMode {
        case .working: startNextBreak()
        case .onShortBreak, .onLongBreak, .paused: startNextWorkInterval()
        }
        // Play sound only if transitioning from a break/paused state to working
        if previousMode != .working && currentMode == .working {
            NSSound(named: settings.soundName)?.play()
            print("BreakTimer: Playing end of break sound.")
        }
        print("BreakTimer: transitionToNextState() finished. currentMode: \(currentMode)")
    }
    
    func skipBreak() {
        print("BreakTimer: skipBreak() called. currentMode: \(currentMode)")
        NotificationManager.shared.cancelNotifications()
        if currentMode == .onShortBreak || currentMode == .onLongBreak { startNextWorkInterval() }
        print("BreakTimer: skipBreak() finished.")
    }

    private func startNextWorkInterval() {
        print("BreakTimer: startNextWorkInterval() called. workCycle: \(workCycle)")
        workCycle = (workCycle + 1) % 2
        currentMode = .working
        let duration = (workCycle == 1) ? settings.shortBreakInterval : settings.longBreakInterval
        targetDate = Date().addingTimeInterval(duration)
        scheduleNotification(duration: duration)
        print("BreakTimer: startNextWorkInterval() finished. currentMode: \(currentMode), targetDate: \(String(describing: targetDate))")
    }

    private func startNextBreak() {
        print("BreakTimer: startNextBreak() called. workCycle: \(workCycle)")
        let duration: TimeInterval
        if workCycle == 1 {
            currentMode = .onShortBreak
            duration = settings.shortBreakDuration
        } else {
            currentMode = .onLongBreak
            duration = settings.longBreakDuration
        }
        targetDate = Date().addingTimeInterval(duration)
        print("BreakTimer: startNextBreak() finished. currentMode: \(currentMode), targetDate: \(String(describing: targetDate))")
    }

    private func startInternalTimer() {
        print("BreakTimer: startInternalTimer() called.")
        timer?.cancel()
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in self?.tick() }
        print("BreakTimer: startInternalTimer() finished.")
    }

    private func tick() {
        // print("BreakTimer: tick() called. isRunning: \(isRunning), currentMode: \(currentMode)") // Too verbose
        guard isRunning else { return }
        if let pausedUntil = pausedUntil, Date() >= pausedUntil {
            print("BreakTimer: tick(): Paused until time reached. Calling start().")
            start(); return
        }
        if currentMode == .paused {
            // print("BreakTimer: tick(): In paused mode, not ticking down.") // Too verbose
            return
        }
        if idleMonitor.getIdleTime() > settings.idleThreshold && currentMode == .working {
            print("BreakTimer: tick(): User is idle, resetting work timer.")
            startNextWorkInterval()
            return
        }
        if let targetDate = targetDate {
            let remaining = max(0, targetDate.timeIntervalSinceNow)
            if remaining > 0 {
                // Update timeRemainingFormatted for UI display
                let minutes = Int(remaining) / 60
                let seconds = Int(remaining) % 60
                timeRemainingFormatted = String(format: "%02d:%02d", minutes, seconds)
            } else {
                print("BreakTimer: tick(): Target date reached. Transitioning state.")
                transitionToNextState()
            }
        }
    }

    private func scheduleNotification(duration: TimeInterval) {
        print("BreakTimer: scheduleNotification() called. duration: \(duration)")
        NotificationManager.shared.cancelNotifications()
        guard settings.areNotificationsEnabled, currentMode == .working else { 
            print("BreakTimer: scheduleNotification() guard: Notifications not enabled or not in working mode.")
            return
        }
        let isShortBreakNext = workCycle == 1
        let notificationTime = isShortBreakNext ? 30.0 : 60.0
        let breakType = isShortBreakNext ? "short" : "long"
        if duration > notificationTime {
            NotificationManager.shared.scheduleNotification(timeRemaining: duration, breakType: breakType)
            print("BreakTimer: Notification scheduled for \(breakType) break in \(Int(duration - notificationTime)) seconds.")
        } else {
            print("BreakTimer: Notification not scheduled: duration (\(duration)) <= notificationTime (\(notificationTime)).")
        }
    }
}

class IdleTimeMonitor {
    func getIdleTime() -> TimeInterval {
        let anyEventType = CGEventType(rawValue: ~0)!
        return CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyEventType)
    }
}