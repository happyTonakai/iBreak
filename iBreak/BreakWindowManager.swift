import SwiftUI

class BreakWindowManager {
    private var breakWindows: [NSWindow] = []

    func showBreakWindows(with timer: BreakTimer) {
        hideBreakWindows() // Close any existing windows first

        for screen in NSScreen.screens {
            let breakView = BreakView().environmentObject(timer)
            let hostingController = NSHostingController(rootView: breakView)
            let window = NSWindow(contentViewController: hostingController)

            window.styleMask = [.borderless]
            window.level = .floating
            window.setFrame(screen.frame, display: true)
            window.makeKeyAndOrderFront(nil)

            breakWindows.append(window)
        }
    }

    func hideBreakWindows() {
        breakWindows.forEach { $0.close() }
        breakWindows.removeAll()
    }
}
