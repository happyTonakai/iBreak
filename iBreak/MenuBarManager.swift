import AppKit
import SwiftUI
import Combine

class MenuBarManager: NSObject {
    static let shared = MenuBarManager()

    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()
    private let breakTimer = BreakTimer.shared
    private let settings = SettingsManager.shared

    private override init() {
        super.init()
    }

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        setupMenu()
        observeTimer()
        updateTitle()
    }

    private func setupMenu() {
        let menu = NSMenu()
        let hostingView = NSHostingView(rootView:
            MenuView()
                .environmentObject(breakTimer)
        )
        // Give the hosting view a reasonable size
        hostingView.frame = NSRect(x: 0, y: 0, width: 220, height: 420)

        let menuItem = NSMenuItem()
        menuItem.view = hostingView
        menu.addItem(menuItem)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit iBreak", action: #selector(quitApp), keyEquivalent: "q")

        // Wire up the menu items' targets
        if let quitItem = menu.items.last {
            quitItem.target = self
        }

        statusItem?.menu = menu
    }

    private func observeTimer() {
        breakTimer.$timeRemainingFormatted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateTitle() }
            .store(in: &cancellables)

        breakTimer.$currentMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateTitle() }
            .store(in: &cancellables)

        breakTimer.$isRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateTitle() }
            .store(in: &cancellables)

        settings.$showMenuBarIcon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                if show {
                    self?.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
                    self?.setupButton()
                    self?.setupMenu()
                } else {
                    if let item = self?.statusItem {
                        NSStatusBar.system.removeStatusItem(item)
                        self?.statusItem = nil
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func setupButton() {
        if let button = statusItem?.button {
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func updateTitle() {
        guard settings.showMenuBarIcon, let button = statusItem?.button else { return }

        if breakTimer.currentMode == .working {
            let isLongBreakNext = breakTimer.workCycle == 0
            let timerText = breakTimer.timeRemainingFormatted + (isLongBreakNext ? " •" : "")
            button.title = timerText
        } else {
            button.title = "☕"
        }
    }

    @objc private func statusItemClicked() {
        // Menu is shown automatically by NSStatusItem when menu is set
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
