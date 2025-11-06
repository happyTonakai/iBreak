# iBreak - macOS Pomodoro Timer

A modern macOS break timer application built with SwiftUI that implements the Pomodoro Technique with intelligent idle detection and multi-monitor support.

## Features

- **Pomodoro Technique Implementation** - Customizable work/break intervals with automatic cycling
- **Menu Bar Integration** - Unobtrusive menu bar icon with timer display
- **Full-Screen Break Windows** - Covers all connected monitors during breaks
- **Smart Idle Detection** - Automatically pauses timer when you're away from keyboard
- **Screen Lock Detection** - Intelligently handles screen lock/unlock events
- **System Notifications** - Native macOS notifications for break reminders
- **Multiple Themes** - Choose from various visual themes for break screens
- **Sound Alerts** - Customizable audio notifications
- **Launch at Login** - Option to automatically start when you log in
- **Strict Mode** - Prevent skipping breaks when enabled

## Requirements

- **macOS**: 14.0 (Sonoma) or later
- **Xcode**: 15.0 or later
- **Swift**: 5.0+
- **Architecture**: Apple Silicon (M1/M2/M3) or Intel Mac

## Installation

### Option 1: Build from Source (Recommended)

#### Prerequisites
1. Install Xcode 15.0+ from the Mac App Store
2. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

#### Building the Application

1. **Clone the repository** (if applicable) or navigate to the project directory:
   ```bash
   cd /path/to/iBreak
   ```

2. **Open the project in Xcode**:
   ```bash
   open iBreak.xcodeproj
   ```

3. **Configure signing** (for personal use):
   - In Xcode, select the "iBreak" target
   - Go to the "Signing & Capabilities" tab
   - Set "Team" to your Apple ID (or "None" for local builds)
   - Ensure "Automatically manage signing" is checked

4. **Build the application**:

   **Debug Build** (for development/testing):
   ```bash
   # Using Xcode GUI: Product → Build (⌘+B)
   # Or using command line:
   xcodebuild -project iBreak.xcodeproj -scheme iBreak -configuration Debug build
   ```

   **Release Build** (for distribution/personal use):
   ```bash
   # Using Xcode GUI: Product → Archive (⌘+Shift+B)
   # Or using command line:
   xcodebuild -project iBreak.xcodeproj -scheme iBreak -configuration Release archive -archivePath ./build/iBreak.xcarchive
   ```

5. **Export the application** (Release build only):
   ```bash
   # From the archive created above:
   xcodebuild -exportArchive -archivePath ./build/iBreak.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
   ```

   Create an `ExportOptions.plist` file with this content:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>method</key>
       <string>development</string>
       <key>teamID</key>
       <string>YOUR_TEAM_ID</string>
       <key>compileBitcode</key>
       <false/>
       <key>signingStyle</key>
       <string>automatic</string>
       <key>destination</key>
       <string>export</string>
   </dict>
   </plist>
   ```

6. **Install the application**:
   ```bash
   # Copy to Applications folder
   cp -R "./build/iBreak.app" "/Applications/"
   
   # Or use Finder to drag the built app to /Applications
   ```

### Option 2: Direct Xcode Build

1. Open `iBreak.xcodeproj` in Xcode
2. Select your Mac as the target device
3. Press `⌘+R` to build and run
4. Right-click the app icon in Dock → Options → Keep in Dock

### Option 3: Using the Built Product

After building, find the app at:
- **Debug**: `~/Library/Developer/Xcode/DerivedData/iBreak-*/Build/Products/Debug/iBreak.app`
- **Release**: `~/Library/Developer/Xcode/DerivedData/iBreak-*/Build/Products/Release/iBreak.app`

## First Launch Setup

### Granting Permissions

1. **Accessibility Permissions** (Required for idle detection):
   - On first launch, iBreak will prompt for accessibility permissions
   - Click "Grant Permission" and follow the System Settings instructions
   - Find "iBreak" in System Settings → Privacy & Security → Accessibility
   - Toggle the switch to enable
   - Restart iBreak after granting permissions

2. **Notification Permissions** (Optional but recommended):
   - Allow notifications when prompted to receive break reminders

### Initial Configuration

1. Open iBreak from your Applications folder
2. Click the menu bar icon to access settings
3. Configure your preferred:
   - Work duration (default: 25 minutes)
   - Short break duration (default: 5 minutes)
   - Long break duration (default: 15 minutes)
   - Theme and sound preferences

## Build Configuration Differences

### Debug Build
- **Purpose**: Development and testing
- **Features**: 
  - Debug symbols included
  - No code optimization
  - Faster compilation times
  - Additional logging enabled
  - Can be run directly from Xcode
- **Size**: Larger file size
- **Performance**: Slower execution
- **Use Case**: Active development, debugging

### Release Build
- **Purpose**: Distribution and personal use
- **Features**:
  - Code optimization enabled
  - Debug symbols stripped
  - Smaller file size
  - Better performance
  - Can be archived and signed
- **Size**: Smaller file size
- **Performance**: Optimized execution
- **Use Case**: Daily use, sharing with others

## Troubleshooting

### Common Issues

#### 1. App Won't Start (Gatekeeper)
```bash
# If you get "iBreak.app can't be opened because Apple cannot check it for malicious software"
sudo xattr -rd com.apple.quarantine "/Applications/iBreak.app"
```

#### 2. Accessibility Permissions Not Working
- Ensure you've granted permissions in System Settings
- Restart the application after granting permissions
- If issues persist, try toggling the permission off and on again

#### 3. Build Errors
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/iBreak-*

# Or use Xcode: Product → Clean Build Folder (⌘+Shift+K)
```

#### 4. Code Signing Issues
- For personal use, set "Team" to "None" in Xcode signing settings
- Or use your personal Apple ID for code signing
- Ensure your Apple ID is added to Xcode preferences

#### 5. Menu Bar Icon Not Showing
- Check "Show Menu Bar Icon" in settings
- Restart the application
- Verify the app isn't hidden in System Settings → Control Center

#### 6. Break Windows Not Appearing
- Ensure accessibility permissions are granted
- Check that "Strict Mode" is enabled if windows should be non-dismissible
- Verify the app isn't in full-screen mode when break starts

### Debug Mode

To enable debug logging:
1. Open Console.app
2. Search for "iBreak"
3. Filter by process to see detailed logs

### Resetting Settings

To reset all settings to defaults:
```bash
# Delete UserDefaults for iBreak
defaults delete com.yourcompany.iBreak

# Or use Finder to delete: ~/Library/Preferences/com.yourcompany.iBreak.plist
```

## Development Notes

### Architecture Overview

iBreak is built using modern macOS development practices:

- **SwiftUI**: Declarative UI framework for the interface
- **Combine**: Reactive programming for state management
- **AppKit Integration**: Native macOS features like menu bar extras
- **Core Foundation**: Low-level system integration for idle detection

### Key Components

- **`iBreakApp.swift`**: Main app entry point and menu bar integration
- **`BreakTimer.swift`**: Core timer logic and state management
- **`BreakWindowManager.swift`**: Full-screen window management
- **`AccessibilityPermissionManager.swift`**: Permission handling
- **`SettingsManager.swift`**: User preferences and persistence
- **`NotificationManager.swift`**: System notification handling

### Project Structure

```
iBreak/
├── iBreakApp.swift              # Main app and menu bar
├── BreakTimer.swift             # Timer logic
├── BreakWindowManager.swift     # Window management
├── SettingsManager.swift        # User settings
├── AccessibilityPermissionManager.swift
├── NotificationManager.swift    # System notifications
├── ScreenLockObserver.swift     # Screen lock detection
├── GlobalKeyMonitor.swift       # Global key monitoring
├── LaunchAtLoginManager.swift   # Login item management
├── Views/
│   ├── SettingsView.swift       # Settings interface
│   ├── MenuView.swift           # Menu bar menu
│   └── BreakView.swift          # Break screen view
├── Resources/
│   └── Assets.xcassets          # Images and icons
└── iBreak.entitlements          # App entitlements
```

### Build Targets

- **iBreak**: Main application target
- **iBreakTests**: Unit tests
- **iBreakUITests**: UI automation tests

### Code Signing and Distribution

For personal use, iBreak can be distributed as:
1. **Unsigned**: Works on your Mac only
2. **Self-signed**: Works on any Mac where you trust the certificate
3. **Apple ID signed**: Works on any Mac (limited distribution)

### Contributing

When making changes:
1. Test on both Debug and Release builds
2. Verify accessibility permissions work correctly
3. Test multi-monitor scenarios
4. Ensure backward compatibility with settings

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and feature requests:
1. Check the troubleshooting section above
2. Review existing issues (if in a repository)
3. Create a new issue with detailed information about your macOS version and steps to reproduce

---

**Note**: iBreak is designed for personal productivity and is not intended for enterprise deployment or App Store distribution without additional configuration and testing.