
import Foundation
import OSLog

class ScreenLockObserver {
    init() {
        let dnc = DistributedNotificationCenter.default()

        dnc.addObserver(
            self,
            selector: #selector(screenIsLocked),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )

        dnc.addObserver(
            self,
            selector: #selector(screenIsUnlocked),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )
    }

    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }

    @objc private func screenIsLocked() {
        Logger.log("Screen is locked. Stopping timer.", type: .info)
        // Preserve the current state (including paused state) when screen is locked
        BreakTimer.shared.stop(preserveState: true)
    }

    @objc private func screenIsUnlocked() {
        Logger.log("Screen is unlocked.", type: .info)
        
        // Check if the timer is paused
        if BreakTimer.shared.isPaused() {
            Logger.log("Timer is paused, keeping it paused after screen unlock.", type: .info)
            // Don't reset the timer if it's paused, just start the internal timer to continue checking for unpause time
            BreakTimer.shared.startInternalTimer()
        } else {
            Logger.log("Timer is not paused, resetting timer after screen unlock.", type: .info)
            // Only reset if the timer was actually running before screen lock
            BreakTimer.shared.start(reset: true)
        }
    }
}
