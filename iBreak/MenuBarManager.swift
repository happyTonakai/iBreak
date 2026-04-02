import AppKit
import Combine

class MenuBarManager: NSObject {
    static let shared = MenuBarManager()

    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private var cancellables = Set<AnyCancellable>()
    private let breakTimer = BreakTimer.shared
    private let settings = SettingsManager.shared

    // Menu item references for dynamic updates
    private var statusMenuItem: NSMenuItem?
    private var startTimerMenuItem: NSMenuItem?
    private var skipBreakMenuItem: NSMenuItem?
    private var resumeTimerMenuItem: NSMenuItem?
    private var pauseHeaderMenuItem: NSMenuItem?
    private var pause30MenuItem: NSMenuItem?
    private var pause1HourMenuItem: NSMenuItem?
    private var pause2HoursMenuItem: NSMenuItem?
    private var pauseUntilMorningMenuItem: NSMenuItem?
    private var pauseIndefinitelyMenuItem: NSMenuItem?
    private var pauseSeparatorMenuItem: NSMenuItem?
    private var resumeSeparatorMenuItem: NSMenuItem?

    private override init() {
        super.init()
    }

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        }

        setupMenu()
        observeTimer()
        updateTitle()
    }

    private func setupMenu() {
        menu = NSMenu()
        guard let menu = menu else { return }

        // Status item (disabled, just shows info)
        statusMenuItem = NSMenuItem(title: NSLocalizedString("Status: Working", comment: ""), action: nil, keyEquivalent: "")
        statusMenuItem?.isEnabled = false
        menu.addItem(statusMenuItem!)

        menu.addItem(.separator())

        // Settings
        menu.addItem(withTitle: NSLocalizedString("Settings...", comment: ""), action: #selector(openSettings), keyEquivalent: ",")

        menu.addItem(.separator())

        // Start Timer (shown when not running)
        startTimerMenuItem = NSMenuItem(title: NSLocalizedString("Start Timer", comment: ""), action: #selector(startTimer), keyEquivalent: "")
        menu.addItem(startTimerMenuItem!)

        // Skip to Break
        skipBreakMenuItem = NSMenuItem(title: NSLocalizedString("Skip to Break", comment: ""), action: #selector(skipBreak), keyEquivalent: "")
        menu.addItem(skipBreakMenuItem!)

        menu.addItem(.separator())

        // Pause header
        pauseHeaderMenuItem = NSMenuItem(title: NSLocalizedString("Pause for...", comment: ""), action: nil, keyEquivalent: "")
        pauseHeaderMenuItem?.isEnabled = false
        menu.addItem(pauseHeaderMenuItem!)

        // Pause options
        pause30MenuItem = NSMenuItem(title: NSLocalizedString("30 minutes", comment: ""), action: #selector(pauseFor30Minutes), keyEquivalent: "")
        menu.addItem(pause30MenuItem!)

        pause1HourMenuItem = NSMenuItem(title: NSLocalizedString("1 hour", comment: ""), action: #selector(pauseFor1Hour), keyEquivalent: "")
        menu.addItem(pause1HourMenuItem!)

        pause2HoursMenuItem = NSMenuItem(title: NSLocalizedString("2 hours", comment: ""), action: #selector(pauseFor2Hours), keyEquivalent: "")
        menu.addItem(pause2HoursMenuItem!)

        pauseUntilMorningMenuItem = NSMenuItem(title: NSLocalizedString("Until tomorrow morning", comment: ""), action: #selector(pauseUntilMorning), keyEquivalent: "")
        menu.addItem(pauseUntilMorningMenuItem!)

        pauseIndefinitelyMenuItem = NSMenuItem(title: NSLocalizedString("Indefinitely", comment: ""), action: #selector(pauseIndefinitely), keyEquivalent: "")
        menu.addItem(pauseIndefinitelyMenuItem!)

        // Resume separator and item (initially hidden)
        resumeSeparatorMenuItem = NSMenuItem.separator()
        menu.addItem(resumeSeparatorMenuItem!)

        resumeTimerMenuItem = NSMenuItem(title: NSLocalizedString("Resume Timer", comment: ""), action: #selector(resumeTimer), keyEquivalent: "")
        menu.addItem(resumeTimerMenuItem!)

        menu.addItem(.separator())

        // Version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let versionItem = NSMenuItem(title: String(format: NSLocalizedString("Version %@", comment: ""), version), action: nil, keyEquivalent: "")
        versionItem.isEnabled = false
        menu.addItem(versionItem)

        // Quit
        menu.addItem(withTitle: NSLocalizedString("Quit iBreak", comment: ""), action: #selector(quitApp), keyEquivalent: "q")

        // Set targets
        for item in menu.items {
            if item.target == nil && item.action != nil {
                item.target = self
            }
        }

        statusItem?.menu = menu
    }

    private func observeTimer() {
        breakTimer.$timeRemainingFormatted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateTitle(); self?.updateMenuState() }
            .store(in: &cancellables)

        breakTimer.$currentMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateTitle(); self?.updateMenuState() }
            .store(in: &cancellables)

        breakTimer.$isRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateTitle(); self?.updateMenuState() }
            .store(in: &cancellables)

        settings.$showMenuBarIcon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                if show {
                    self?.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
                    if let button = self?.statusItem?.button {
                        button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
                    }
                    self?.statusItem?.menu = self?.menu
                    self?.updateTitle()
                } else {
                    if let item = self?.statusItem {
                        NSStatusBar.system.removeStatusItem(item)
                        self?.statusItem = nil
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func updateTitle() {
        guard settings.showMenuBarIcon, let button = statusItem?.button else { return }

        if breakTimer.currentMode == .working {
            let isLongBreakNext = breakTimer.isLongBreakNext
            let timerText = breakTimer.timeRemainingFormatted + (isLongBreakNext ? " •" : "")
            button.title = timerText
        } else {
            button.title = "☕"
        }
    }

    private func updateMenuState() {
        let mode = breakTimer.currentMode
        let isRunning = breakTimer.isRunning
        let isPaused = mode == .paused

        // Update status text
        let nextBreakType = breakTimer.isLongBreakNext ? NSLocalizedString("Long Break", comment: "") : NSLocalizedString("Short Break", comment: "")
        switch mode {
        case .working:
            statusMenuItem?.title = String(format: NSLocalizedString("Status: Working - %@", comment: ""), nextBreakType)
        case .onShortBreak:
            statusMenuItem?.title = NSLocalizedString("Status: Short Break", comment: "")
        case .onLongBreak:
            statusMenuItem?.title = NSLocalizedString("Status: Long Break", comment: "")
        case .paused:
            statusMenuItem?.title = NSLocalizedString("Status: Paused", comment: "")
        }

        // Start Timer: only show when not running and not paused
        startTimerMenuItem?.isHidden = isRunning || isPaused

        // Skip to Break: show when working or on break
        skipBreakMenuItem?.isHidden = isPaused

        // Pause items: show when working (not on break, not paused)
        let showPauseItems = mode == .working && isRunning
        pauseHeaderMenuItem?.isHidden = !showPauseItems
        pause30MenuItem?.isHidden = !showPauseItems
        pause1HourMenuItem?.isHidden = !showPauseItems
        pause2HoursMenuItem?.isHidden = !showPauseItems
        pauseUntilMorningMenuItem?.isHidden = !showPauseItems
        pauseIndefinitelyMenuItem?.isHidden = !showPauseItems
        pauseSeparatorMenuItem?.isHidden = !showPauseItems

        // Resume items: only show when paused
        resumeSeparatorMenuItem?.isHidden = !isPaused
        resumeTimerMenuItem?.isHidden = !isPaused
    }

    // MARK: - Actions

    @objc private func openSettings() {
        Task { @MainActor in
            SettingsWindowManager.shared.open()
        }
    }

    @objc private func startTimer() {
        breakTimer.start(reset: true)
    }

    @objc private func skipBreak() {
        breakTimer.transitionToNextState()
    }

    @objc private func pauseFor30Minutes() {
        breakTimer.pause(for: .thirtyMinutes)
    }

    @objc private func pauseFor1Hour() {
        breakTimer.pause(for: .oneHour)
    }

    @objc private func pauseFor2Hours() {
        breakTimer.pause(for: .twoHours)
    }

    @objc private func pauseUntilMorning() {
        breakTimer.pause(for: .untilMorning)
    }

    @objc private func pauseIndefinitely() {
        breakTimer.pause(for: .indefinitely)
    }

    @objc private func resumeTimer() {
        breakTimer.start(reset: false)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
