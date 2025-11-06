
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
        BreakTimer.shared.stop()
    }

    @objc private func screenIsUnlocked() {
        Logger.log("Screen is unlocked. Resetting timer.", type: .info)
        BreakTimer.shared.start(reset: true)
    }
}
