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
        // Use SMAppService for managing login items, available from macOS 13.0.
        // For older macOS versions, you might need to conditionally compile or provide a fallback.
        if #available(macOS 13.0, *) {
            let appService = SMAppService.mainApp
            do {
                if enabled {
                    try appService.register()
                    Logger.log("Successfully registered app for launch at login.", type: .info)
                } else {
                    try appService.unregister()
                    Logger.log("Successfully unregistered app from launch at login.", type: .info)
                }
            } catch {
                Logger.log("Failed to update launch at login status with SMAppService: \(error.localizedDescription)", type: .error)
                // If the system call fails, revert the toggle to show the correct state.
                DispatchQueue.main.async {
                    self.isEnabled.toggle()
                }
            }
        } else {
            // Fallback for macOS versions prior to 13.0, if you still need to support them.
            // This is the older, but more compatible, function for managing login items.
            // It requires the app's unique bundle identifier.
            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                Logger.log("Could not get bundle identifier.", type: .error)
                return
            }

            if SMLoginItemSetEnabled(bundleIdentifier as CFString, enabled) {
                Logger.log("Successfully updated launch at login status to \(enabled) using SMLoginItemSetEnabled", type: .info)
            } else {
                Logger.log("Failed to update launch at login status using SMLoginItemSetEnabled.", type: .error)
                // If the system call fails, revert the toggle to show the correct state.
                DispatchQueue.main.async {
                    self.isEnabled.toggle()
                }
            }
        }
    }
}
