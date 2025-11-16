import Foundation
import Combine
import SwiftUI
import AVFoundation // Import AVFoundation for NSSound
import OSLog
import CoreGraphics // For CGEventSource and CGEvent
import ApplicationServices // For kCGEventMouseMoved and CGPostMouseEvent

enum TimerMode: String {
    case working, onShortBreak, onLongBreak, paused
}

enum PauseDuration: TimeInterval {
    case thirtyMinutes = 1800, oneHour = 3600, twoHours = 7200, untilMorning = -1, indefinitely = -2
}

class BreakTimer: ObservableObject {
    static let shared = BreakTimer()
    
    @Published var timeRemainingFormatted: String = "00:00"
    @Published var isRunning = false
    @Published var currentMode: TimerMode = .working
    @Published var targetDate: Date?

    private let settings = SettingsManager.shared
    var workCycle = 0
    private var idleMonitor = IdleTimeMonitor()
    private var timer: AnyCancellable?
    private var pausedUntil: Date?

    private init() {
        Logger.log("BreakTimer: init() called.", type: .debug)
        start(reset: true)
    }

    func start(reset: Bool = false) {
        Logger.log("BreakTimer: start() called. isRunning: \(isRunning), currentMode: \(currentMode)", type: .debug)
        NotificationManager.shared.cancelNotifications() // Clear any old notifications
        
        // No guard here. Always attempt to start/resume.
        isRunning = true
        pausedUntil = nil
        
        // If we were paused, or just starting, set to working mode and start a new work interval.
        if currentMode == .paused || targetDate == nil {
            currentMode = .working
            startNextWorkInterval(reset: reset)
        }
        startInternalTimer()
        Logger.log("BreakTimer: start() finished. isRunning: \(isRunning), currentMode: \(currentMode)", type: .debug)
    }

    func stop(preserveState: Bool = false) {
        Logger.log("BreakTimer: stop() called. isRunning: \(isRunning), currentMode: \(currentMode), preserveState: \(preserveState)", type: .debug)
        isRunning = false
        targetDate = nil
        timer?.cancel()
        // When stopped, explicitly set mode to working, ready for a fresh start, unless preserving state
        if !preserveState {
            currentMode = .working
        }
        Logger.log("BreakTimer: stop() finished. currentMode: \(currentMode)", type: .debug)
    }
    
    func isPaused() -> Bool {
        return currentMode == .paused
    }
    
    func pause(for duration: PauseDuration) {
        Logger.log("BreakTimer: pause(for: \(duration)) called. currentMode: \(currentMode)", type: .debug)
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
        Logger.log("BreakTimer: pause() finished. currentMode: \(currentMode)", type: .debug)
    }

    func transitionToNextState() {
        Logger.log("BreakTimer: transitionToNextState() called. currentMode: \(currentMode)", type: .debug)
        let previousMode = currentMode // Capture current mode before changing
        switch currentMode {
        case .working: startNextBreak()
        case .onShortBreak, .onLongBreak, .paused: startNextWorkInterval()
        }
        // Play sound only if transitioning from a break/paused state to working
        if previousMode != .working && currentMode == .working {
            NSSound(named: settings.soundName)?.play()
            Logger.log("BreakTimer: Playing end of break sound.", type: .info)
        }
        Logger.log("BreakTimer: transitionToNextState() finished. currentMode: \(currentMode)", type: .debug)
    }
    
    func skipBreak() {
        Logger.log("BreakTimer: skipBreak() called. currentMode: \(currentMode)", type: .debug)
        NotificationManager.shared.cancelNotifications()
        if currentMode == .onShortBreak || currentMode == .onLongBreak { startNextWorkInterval() }
        Logger.log("BreakTimer: skipBreak() finished.", type: .debug)
    }

    private func startNextWorkInterval(reset: Bool = false) {
        Logger.log("BreakTimer: startNextWorkInterval() called. workCycle: \(workCycle), reset: \(reset)", type: .debug)
        if reset {
            // When reset is true, we start with a short break
            workCycle = 1
        } else {
            workCycle = (workCycle + 1) % 2
        }
        currentMode = .working
        let duration = (workCycle == 1) ? settings.shortBreakInterval : settings.longBreakInterval
        targetDate = Date().addingTimeInterval(duration)
        scheduleNotification(duration: duration)
        Logger.log("BreakTimer: startNextWorkInterval() finished. currentMode: \(currentMode), targetDate: \(String(describing: targetDate)), workCycle: \(workCycle)", type: .debug)
    }

    private func startNextBreak() {
        Logger.log("BreakTimer: startNextBreak() called. workCycle: \(workCycle)", type: .debug)
        let duration: TimeInterval
        if workCycle == 1 {
            currentMode = .onShortBreak
            duration = settings.shortBreakDuration
        } else {
            currentMode = .onLongBreak
            duration = settings.longBreakDuration
        }
        targetDate = Date().addingTimeInterval(duration)
        Logger.log("BreakTimer: startNextBreak() finished. currentMode: \(currentMode), targetDate: \(String(describing: targetDate))", type: .debug)
    }

    func startInternalTimer() {
        Logger.log("BreakTimer: startInternalTimer() called.", type: .debug)
        timer?.cancel()
        // Only set isRunning to true if not in paused mode
        if currentMode != .paused {
            isRunning = true
        }
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in self?.tick() }
        Logger.log("BreakTimer: startInternalTimer() finished. isRunning: \(isRunning), currentMode: \(currentMode)", type: .debug)
    }

    private func tick() {
        // Always check pause state first, even if not running
        if let pausedUntil = pausedUntil, Date() >= pausedUntil {
            Logger.log("BreakTimer: tick(): Paused until time reached. Calling start().", type: .debug)
            start(reset: false); return
        }
        
        // Check if paused
        if currentMode == .paused {
            // Ensure isRunning is false when paused to maintain consistency
            if isRunning {
                Logger.log("BreakTimer: tick(): Detected inconsistent state - isRunning=true while paused. Fixing.", type: .error)
                isRunning = false
            }
            return
        }
        
        // Only proceed with timer logic if running
        guard isRunning else { return }
        if currentMode == .working {
            let currentIdleTime = idleMonitor.getIdleTime()
            if currentIdleTime > settings.idleThreshold {
                if isVideoPlayingViaPmset() {
					idleMonitor.resetIdleTime()
                    Logger.log("BreakTimer: tick(): User is idle, but video is playing, resetting idle timer.", type: .debug)
                } else {
                    Logger.log("BreakTimer: tick(): User is idle and no video is playing, resetting work timer.", type: .debug)
                    startNextWorkInterval(reset: true)
                }
            }
        }
        if let targetDate = targetDate {
            let remaining = max(0, targetDate.timeIntervalSinceNow)
            if remaining > 0 {
                // Update timeRemainingFormatted for UI display
                let minutes = Int(remaining) / 60
                let seconds = Int(remaining) % 60
                timeRemainingFormatted = String(format: "%02d:%02d", minutes, seconds)
            } else {
                Logger.log("BreakTimer: tick(): Target date reached. Transitioning state.", type: .debug)
                transitionToNextState()
            }
        }
    }

    private func scheduleNotification(duration: TimeInterval) {
        Logger.log("BreakTimer: scheduleNotification() called. duration: \(duration)", type: .debug)
        NotificationManager.shared.cancelNotifications()
        guard settings.areNotificationsEnabled, currentMode == .working else { 
            Logger.log("BreakTimer: scheduleNotification() guard: Notifications not enabled or not in working mode.", type: .debug)
            return
        }
        let isShortBreakNext = workCycle == 1
        let notificationTime = isShortBreakNext ? 30.0 : 60.0
        let breakType = isShortBreakNext ? "short" : "long"
        if duration > notificationTime {
            NotificationManager.shared.scheduleNotification(timeRemaining: duration, breakType: breakType)
            Logger.log("BreakTimer: Notification scheduled for \(breakType) break in \(Int(duration - notificationTime)) seconds.", type: .info)
        } else {
            Logger.log("BreakTimer: Notification not scheduled: duration (\(duration)) <= notificationTime (\(notificationTime)).", type: .info)
        }
    }

    private func isVideoPlayingViaPmset() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["-g"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            Logger.log("pmset -g output:\n\(output)", type: .debug)

            // Check for the general string indicating display sleep prevention
            if output.contains("display sleep prevented by") {
                return true
            }
        }
        return false
    }
}

class IdleTimeMonitor {
    func getIdleTime() -> TimeInterval {
        let anyEventType = CGEventType(rawValue: ~0)!
        return CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyEventType)
    }
    
	func resetIdleTime() {
        // Get the current mouse position
        let currentMouseLocation = CGEvent(source: nil)?.location ?? CGPoint(x: 0, y: 0)
 
        // Move the mouse by 1 pixel (e.g., right then back left, or just right)
        // Moving it just by 1 pixel is often imperceptible to the user.
        let newX = currentMouseLocation.x + 1
        let newY = currentMouseLocation.y
 
        // Create and post a mouse movement event
        guard let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: CGPoint(x: newX, y: newY), mouseButton: .left) else {
            Logger.log("Error: Could not create mouse event.", type: .error)
            return
        }
 
        // Post the event. This injects it into the system's event stream.
        event.post(tap: .cghidEventTap)
 
        Logger.log("Reset idle timer by simulating activity: Mouse moved to (\(newX), \(newY)).", type: .debug)
    }
}