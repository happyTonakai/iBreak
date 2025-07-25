import Foundation
import ServiceManagement
import OSLog

class LaunchAtLoginManager: ObservableObject {
    // We store the user's preference in UserDefaults because there is no clean way
    // to read the setting from the system with this older API.
    @Published var isEnabled: Bool = UserDefaults.standard.bool(forKey: "launchAtLoginEnabled") {
        didSet {
            // When the toggle changes, save the preference and update the system.
            UserDefaults.standard.set(isEnabled, forKey: "launchAtLoginEnabled")
            setSystemLaunchAtLogin(enabled: isEnabled)
        }
    }

    private func setSystemLaunchAtLogin(enabled: Bool) {
        // This is the older, but more compatible, function for managing login items.
        // It requires the app's unique bundle identifier.
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            Logger.log("Could not get bundle identifier.", type: .error)
            return
        }

        if SMLoginItemSetEnabled(bundleIdentifier as CFString, enabled) {
            Logger.log("Successfully updated launch at login status to \(enabled)", type: .info)
        } else {
            Logger.log("Failed to update launch at login status.", type: .error)
            // If the system call fails, revert the toggle to show the correct state.
            DispatchQueue.main.async {
                self.isEnabled.toggle()
            }
        }
    }
}
