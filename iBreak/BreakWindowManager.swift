import SwiftUI

class BreakWindowManager {
    private var breakWindows: [NSWindow] = []

    func showBreakWindows(with timer: BreakTimer) {
        hideBreakWindows() // Close any existing windows first

        for screen in NSScreen.screens {
            let breakView = BreakView().environmentObject(timer)
            let hostingController = NSHostingController(rootView: breakView)
            let window = NSWindow(contentViewController: hostingController)

            // Configure window to cover the entire screen
            window.styleMask = [.borderless, .fullSizeContentView]
            window.level = .screenSaver
            window.backgroundColor = NSColor.clear
            window.isOpaque = false
            window.hasShadow = false
            window.ignoresMouseEvents = false
            
            // Set window frame to match screen exactly
            window.setFrame(screen.visibleFrame, display: false)
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            
            // Make the window visible and bring it to front
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            
            breakWindows.append(window)
        }
    }

    func hideBreakWindows() {
        breakWindows.forEach { $0.close() }
        breakWindows.removeAll()
    }
}
