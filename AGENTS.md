# iBreak - macOS Break Timer Application

## Project Overview

iBreak is a macOS application built with SwiftUI that implements the Pomodoro Technique with customizable work/break intervals. The app runs as a menu bar application that helps users maintain healthy work habits by scheduling regular breaks.

### Key Features
- **Menu Bar Integration**: Runs as a menu bar extra with timer display
- **Customizable Intervals**: Configurable work sessions, short breaks, and long breaks
- **Break Enforcement**: Full-screen break windows that prevent work during breaks
- **Smart Idle Detection**: Pauses timer when user is idle, with video playback detection
- **Notifications**: System notifications before breaks
- **Themes**: Multiple visual themes for break screens
- **Sound Alerts**: Audio notifications for break transitions
- **Launch at Login**: Option to auto-start with system

### Architecture
- **Main App**: SwiftUI-based with `MenuBarExtra` for system integration
- **Timer Logic**: `BreakTimer` class manages state transitions and timing
- **Settings Management**: `SettingsManager` handles UserDefaults persistence
- **Window Management**: `BreakWindowManager` controls full-screen break displays
- **Notifications**: Integration with `UserNotifications` framework
- **Idle Monitoring**: Core Graphics-based idle time detection

## Technology Stack

- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI
- **Platform**: macOS (targeting modern macOS versions)
- **Build System**: Xcode project
- **Testing**: Swift Testing framework
- **System Integration**: 
  - UserNotifications for alerts
  - Core Graphics for idle detection
  - AVFoundation for sound playback
  - ApplicationServices for system-level interactions

## Project Structure

```
iBreak/
├── iBreak/                    # Main application source
│   ├── iBreakApp.swift        # App entry point and main scene setup
│   ├── BreakTimer.swift       # Core timer logic and state management
│   ├── SettingsManager.swift  # User preferences and persistence
│   ├── BreakView.swift        # Full-screen break interface
│   ├── MenuView.swift         # Menu bar dropdown interface
│   ├── SettingsView.swift     # Settings window UI
│   ├── BreakWindowManager.swift # Break window lifecycle management
│   ├── NotificationManager.swift # System notification handling
│   ├── BreakTheme.swift       # Visual theme definitions
│   ├── AccessibilityPermissionManager.swift
│   ├── LaunchAtLoginManager.swift
│   ├── AppDelegate.swift      # Application delegate
│   └── ... (supporting files)
├── iBreakTests/               # Unit tests
├── iBreakUITests/             # UI tests
└── icons/                     # Application icons and assets
```

## Building and Running

### Prerequisites
- macOS 14.0+ (for modern SwiftUI features)
- Xcode 15.0+
- Apple Developer account for code signing (optional for development)

### Development Commands

```bash
# Open project in Xcode
open iBreak.xcodeproj

# Build from command line
xcodebuild -project iBreak.xcodeproj -scheme iBreak -configuration Debug build

# Run tests
xcodebuild test -project iBreak.xcodeproj -scheme iBreak -destination 'platform=macOS'

# Archive for distribution
xcodebuild archive -project iBreak.xcodeproj -scheme iBreak -archivePath ./build/iBreak.xcarchive
```

### Build Configurations
- **Debug**: Development builds with full logging
- **Release**: Optimized builds for distribution

## Development Conventions

### Code Style
- **Swift Naming**: Follows Swift API Design Guidelines
- **File Organization**: One main class/struct per file
- **Access Control**: Private/internal for implementation details, public for APIs
- **Comments**: Minimal inline comments, focus on "why" not "what"

### Architecture Patterns
- **MVVM**: SwiftUI views with `@ObservableObject` view models
- **Dependency Injection**: Environment objects for shared state
- **Singleton Pattern**: Used for `SettingsManager.shared` and `NotificationManager.shared`
- **Delegate Pattern**: For system integration (notifications, app lifecycle)

### State Management
- **Published Properties**: For UI-reactive state in `ObservableObject` classes
- **Environment Objects**: For sharing settings and timer state across views
- **UserDefaults**: For persistent user preferences

### Testing Strategy
- **Unit Tests**: Focus on core logic (`BreakTimer`, `SettingsManager`)
- **UI Tests**: Critical user flows (settings changes, timer operations)
- **Integration Tests**: System interactions (notifications, window management)

### Logging
- **Custom Logger**: Structured logging with different levels (debug, info, error)
- **Debug Focus**: Detailed logging in timer logic and state transitions
- **Production**: Minimal logging for performance

### Key Implementation Details

#### Timer Logic
- Alternates between work sessions and breaks (short/long)
- Idle detection resets work timer when user is inactive
- Video playback detection via `pmset` command
- Supports pause functionality with various duration options

#### Window Management
- Full-screen break windows cover all displays
- Window positioning and lifecycle managed by `BreakWindowManager`
- Accessibility permissions required for proper window control

#### Settings Persistence
- All user preferences stored in UserDefaults
- Default values registered on app launch
- Settings are `@Published` for immediate UI updates

## Common Development Tasks

### Adding New Break Themes
1. Define theme in `BreakTheme.swift`
2. Add theme name to available themes array
3. Update theme selection UI in `SettingsView.swift`

### Modifying Timer Logic
1. Core logic in `BreakTimer.swift`
2. State transitions in `transitionToNextState()`
3. Update `TimerMode` enum if adding new states

### Adding New Settings
1. Add property to `SettingsManager.swift`
2. Include in `Keys` enum and `defaults` dictionary
3. Add UI controls in `SettingsView.swift`
4. Update `save()` and `resetToDefaults()` methods

### Testing Timer Changes
1. Focus on `BreakTimer` unit tests
2. Test state transitions and timing accuracy
3. Verify idle detection behavior
4. Test notification scheduling

## Deployment Notes

### Code Signing
- Requires Apple Developer certificate for distribution
- Entitlements defined in `iBreak.entitlements`
- Accessibility permissions required for full functionality

### App Store Distribution
- Follow macOS App Store guidelines
- Ensure proper privacy policy and data usage documentation
- Test sandboxing compliance if required

### System Requirements
- Minimum macOS version should be specified in `Info.plist`
- Test on various macOS versions for compatibility
- Consider performance impact on older hardware