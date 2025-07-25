import Foundation
import Cocoa
import ApplicationServices

class AccessibilityPermissionManager {
    static let shared = AccessibilityPermissionManager()
    
    private init() {}
    
    /// Check if the app has accessibility permissions
    func hasPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false]
        return AXIsProcessTrustedWithOptions(options)
    }
    
    /// Request accessibility permissions from the user
    func requestPermission(completion: @escaping (Bool) -> Void) {
        // If we already have permission, call completion with true
        if hasPermission() {
            completion(true)
            return
        }
        
        // Show an alert explaining why we need accessibility permissions
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "iBreak needs accessibility permissions to detect when you're idle and automatically reset your work timer. Please click 'Grant Permission', then in the System Settings window, find 'iBreak' and check its box."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Grant Permission")
            alert.addButton(withTitle: "Not Now")
            
            let response = alert.runModal()
            
            if response == .alertFirstButtonReturn {
                // Step 1: Call AXIsProcessTrustedWithOptions with prompt = true
                // This will trigger the *system's* small prompt and ensure your app is added to the list.
                // It will block until the user dismisses that small system prompt.
                // The return value 'didPrompt' indicates if the system prompt was shown.
                let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
                let didPrompt = AXIsProcessTrustedWithOptions(options)
                
                // Note: 'didPrompt' does *not* mean permission was granted, only that the system dialog appeared.
                // The actual permission status is still false at this point if the user hasn't checked the box.
                
                // Step 2: Now, open System Settings to the Accessibility pane using AppleScript.
                // This is needed because AXIsProcessTrustedWithOptions doesn't directly open System Settings.
                let script = "do shell script \"open x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility\""
                var error: NSDictionary?
                if let scriptObject = NSAppleScript(source: script) {
                    scriptObject.executeAndReturnError(&error)
                    if let scriptError = error {
                        Logger.log("Error opening System Settings: \(scriptError)", type: .error)
                    }
                }
                
                // We cannot know immediately if the user granted permission.
                // The user needs to manually check the box in System Settings.
                // The app will likely need to be restarted or the feature re-enabled
                // for the permission change to take effect and be detected by hasPermission().
                completion(false) // Assume false for now, as user hasn't completed action
            } else {
                // User clicked "Not Now" or closed the alert
                completion(false)
            }
        }
    }
}
