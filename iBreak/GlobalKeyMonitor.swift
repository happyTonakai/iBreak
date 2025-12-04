import Cocoa
import Combine

class GlobalKeyMonitor: ObservableObject {
    static let shared = GlobalKeyMonitor()
    
    private var globalKeyMonitor: Any?
    private var localKeyMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isMonitoring = false
    
    private init() {}
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        Logger.log("GlobalKeyMonitor: Starting key monitoring", type: .debug)
        
        // Always start local monitoring (works when app is focused, no permissions needed)
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            
            // If this is an ESC key and we're on a break, consume the event
            // to prevent it from being passed to other applications
            if event.keyCode == 53 {
                let timer = BreakTimer.shared
                if timer.currentMode == .onShortBreak || timer.currentMode == .onLongBreak {
                    return nil // Consume the ESC event
                }
            }
            
            return event // Return the event to let it continue processing
        }
        
        // Try global monitoring (requires accessibility permissions)
        if AccessibilityPermissionManager.shared.hasPermission() {
            globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                self?.handleKeyEvent(event)
            }
            Logger.log("GlobalKeyMonitor: Global key monitoring started", type: .info)
        } else {
            Logger.log("GlobalKeyMonitor: Only local key monitoring available (no accessibility permissions)", type: .info)
            requestAccessibilityPermission()
        }
        
        isMonitoring = true
        Logger.log("GlobalKeyMonitor: Key monitoring started successfully", type: .info)
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        Logger.log("GlobalKeyMonitor: Stopping key monitoring", type: .debug)
        
        if let globalMonitor = globalKeyMonitor {
            NSEvent.removeMonitor(globalMonitor)
            globalKeyMonitor = nil
        }
        
        if let localMonitor = localKeyMonitor {
            NSEvent.removeMonitor(localMonitor)
            localKeyMonitor = nil
        }
        
        isMonitoring = false
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        // Log all key events for debugging (only in debug mode)
        Logger.log("GlobalKeyMonitor: Key pressed - keyCode: \(event.keyCode), characters: \(event.characters ?? "none")", type: .debug)
        
        // Check if the key pressed is ESC (keyCode 53 on macOS)
        if event.keyCode == 53 {
            Logger.log("GlobalKeyMonitor: ESC key detected!", type: .info)
            
            // Check if we're currently on a break
            let timer = BreakTimer.shared
            Logger.log("GlobalKeyMonitor: Current timer mode: \(timer.currentMode.rawValue)", type: .debug)
            
            if timer.currentMode == .onShortBreak || timer.currentMode == .onLongBreak {
                Logger.log("GlobalKeyMonitor: Cancelling break due to ESC key", type: .info)
                timer.skipBreak()
            } else {
                Logger.log("GlobalKeyMonitor: Not on break, ignoring ESC key", type: .debug)
            }
        }
    }
    
    private func requestAccessibilityPermission() {
        AccessibilityPermissionManager.shared.requestPermission { [weak self] granted in
            if granted {
                Logger.log("GlobalKeyMonitor: Accessibility permission granted, attempting to start monitoring", type: .info)
                DispatchQueue.main.async {
                    self?.startMonitoring()
                }
            } else {
                Logger.log("GlobalKeyMonitor: Accessibility permission denied", type: .error)
            }
        }
    }
    
    deinit {
        stopMonitoring()
    }
}