import Cocoa
import Combine

class GlobalKeyMonitor: ObservableObject {
    static let shared = GlobalKeyMonitor()
    
    private var globalKeyMonitor: Any?
    private var localKeyMonitor: Any?
    private var eventTap: CFMachPort?
    private var eventTapSource: CFRunLoopSource?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isMonitoring = false
    
    private init() {}
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        Logger.log("GlobalKeyMonitor: Starting key monitoring", type: .debug)
        
        // Always start local monitoring (works when app is focused, no permissions needed)
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            
            // If we're on a break, consume ALL key events to prevent them from reaching other apps
            let timer = BreakTimer.shared
            if timer.currentMode == .onShortBreak || timer.currentMode == .onLongBreak {
                return nil // Consume the event
            }
            
            return event // Return the event to let it continue processing
        }
        
        // Try global monitoring with CGEventTap for actual event blocking
        if AccessibilityPermissionManager.shared.hasPermission() {
            startEventTap()
            Logger.log("GlobalKeyMonitor: Global key monitoring started with CGEventTap", type: .info)
        } else {
            Logger.log("GlobalKeyMonitor: Only local key monitoring available (no accessibility permissions)", type: .info)
            requestAccessibilityPermission()
        }
        
        isMonitoring = true
        Logger.log("GlobalKeyMonitor: Key monitoring started successfully", type: .info)
    }
    
    private func startEventTap() {
        stopEventTap()
        
        // Create an event tap that intercepts all keyboard events
        let eventsOfInterest = CGEventMask(1 << CGEventType.keyDown.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventsOfInterest,
            callback: { proxy, type, event, refcon -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let monitor = Unmanaged<GlobalKeyMonitor>.fromOpaque(refcon).takeUnretainedValue()
                
                let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                let timer = BreakTimer.shared
                
                if timer.currentMode == .onShortBreak || timer.currentMode == .onLongBreak {
                    // On break: block all keys except backspace (which triggers skipBreak if not strict mode)
                    if keyCode == 51 {
                        // Backspace: call skipBreak but still block the event from reaching other apps
                        DispatchQueue.main.async {
                            monitor.handleBackspace()
                        }
                    }
                    // Block ALL keyboard events during break
                    return nil
                }
                
                // Not on break: let events through
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            Logger.log("GlobalKeyMonitor: Failed to create CGEventTap", type: .error)
            return
        }
        
        eventTap = tap
        eventTapSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        
        if let source = eventTapSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }
    
    private func stopEventTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = eventTapSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
            eventTap = nil
            eventTapSource = nil
        }
    }
    
    private func handleBackspace() {
        Logger.log("GlobalKeyMonitor: Backspace key detected during break!", type: .info)
        let timer = BreakTimer.shared
        Logger.log("GlobalKeyMonitor: Current timer mode: \(timer.currentMode.rawValue)", type: .debug)
        
        if timer.currentMode == .onShortBreak || timer.currentMode == .onLongBreak {
            Logger.log("GlobalKeyMonitor: Cancelling break due to Backspace key", type: .info)
            timer.skipBreak()
        }
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        Logger.log("GlobalKeyMonitor: Stopping key monitoring", type: .debug)
        
        stopEventTap()
        
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
        Logger.log("GlobalKeyMonitor: Key pressed - keyCode: \(event.keyCode), characters: \(event.characters ?? "none")", type: .debug)
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
