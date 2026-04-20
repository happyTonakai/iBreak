import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // Keys for UserDefaults
    private enum Keys {
        static let shortBreakInterval = "shortBreakInterval"
        static let longBreakInterval = "longBreakInterval"
        static let shortBreakDuration = "shortBreakDuration"
        static let longBreakDuration = "longBreakDuration"
        static let themeName = "themeName"
        static let soundName = "soundName"
        static let idleThreshold = "idleThreshold"
        static let isStrictModeEnabled = "isStrictModeEnabled"
        static let areNotificationsEnabled = "areNotificationsEnabled"
        static let showMenuBarIcon = "showMenuBarIcon"
        static let isForcedEndOfWorkModeEnabled = "isForcedEndOfWorkModeEnabled"
        static let forcedEndOfWorkTime = "forcedEndOfWorkTime"
        static let shortBreaksBeforeLongBreak = "shortBreaksBeforeLongBreak"
    }

    private let defaults: [String: Any] = [
        Keys.shortBreakInterval: 20 * 60,
        Keys.longBreakInterval: 40 * 60,
        Keys.shortBreakDuration: 30,
        Keys.longBreakDuration: 5 * 60,
        Keys.themeName: "Classic Black",
        Keys.soundName: "Tink",
        Keys.idleThreshold: 5 * 60,
        Keys.isStrictModeEnabled: false,
        Keys.areNotificationsEnabled: true,
        Keys.showMenuBarIcon: true,
        Keys.isForcedEndOfWorkModeEnabled: false,
        Keys.forcedEndOfWorkTime: 18 * 3600, // Default 18:00 (6 PM) in seconds from midnight
        Keys.shortBreaksBeforeLongBreak: 1
    ]

    private var isInitializing = true

    @Published var shortBreakInterval: TimeInterval = 0 {
        didSet { if !isInitializing { UserDefaults.standard.set(shortBreakInterval, forKey: Keys.shortBreakInterval) } }
    }
    @Published var longBreakInterval: TimeInterval = 0 {
        didSet { if !isInitializing { UserDefaults.standard.set(longBreakInterval, forKey: Keys.longBreakInterval) } }
    }
    @Published var shortBreakDuration: TimeInterval = 0 {
        didSet { if !isInitializing { UserDefaults.standard.set(shortBreakDuration, forKey: Keys.shortBreakDuration) } }
    }
    @Published var longBreakDuration: TimeInterval = 0 {
        didSet { if !isInitializing { UserDefaults.standard.set(longBreakDuration, forKey: Keys.longBreakDuration) } }
    }
    @Published var themeName: String = "" {
        didSet { if !isInitializing { UserDefaults.standard.set(themeName, forKey: Keys.themeName) } }
    }
    @Published var soundName: String = "" {
        didSet { if !isInitializing { UserDefaults.standard.set(soundName, forKey: Keys.soundName) } }
    }
    @Published var idleThreshold: TimeInterval = 0 {
        didSet { if !isInitializing { UserDefaults.standard.set(idleThreshold, forKey: Keys.idleThreshold) } }
    }
    @Published var isStrictModeEnabled: Bool = false {
        didSet { if !isInitializing { UserDefaults.standard.set(isStrictModeEnabled, forKey: Keys.isStrictModeEnabled) } }
    }
    @Published var areNotificationsEnabled: Bool = false {
        didSet { if !isInitializing { UserDefaults.standard.set(areNotificationsEnabled, forKey: Keys.areNotificationsEnabled) } }
    }
    @Published var showMenuBarIcon: Bool = false {
        didSet { if !isInitializing { UserDefaults.standard.set(showMenuBarIcon, forKey: Keys.showMenuBarIcon) } }
    }
    @Published var isForcedEndOfWorkModeEnabled: Bool = false {
        didSet { if !isInitializing { UserDefaults.standard.set(isForcedEndOfWorkModeEnabled, forKey: Keys.isForcedEndOfWorkModeEnabled) } }
    }
    @Published var forcedEndOfWorkTime: TimeInterval = 0 {
        didSet { if !isInitializing { UserDefaults.standard.set(forcedEndOfWorkTime, forKey: Keys.forcedEndOfWorkTime) } }
    }
    @Published var shortBreaksBeforeLongBreak: Int = 0 {
        didSet { if !isInitializing { UserDefaults.standard.set(shortBreaksBeforeLongBreak, forKey: Keys.shortBreaksBeforeLongBreak) } }
    }

    private init() {
        UserDefaults.standard.register(defaults: defaults)

        shortBreakInterval = UserDefaults.standard.double(forKey: Keys.shortBreakInterval)
        longBreakInterval = UserDefaults.standard.double(forKey: Keys.longBreakInterval)
        shortBreakDuration = UserDefaults.standard.double(forKey: Keys.shortBreakDuration)
        longBreakDuration = UserDefaults.standard.double(forKey: Keys.longBreakDuration)
        themeName = UserDefaults.standard.string(forKey: Keys.themeName) ?? "Classic Black"
        soundName = UserDefaults.standard.string(forKey: Keys.soundName) ?? "Tink"
        idleThreshold = UserDefaults.standard.double(forKey: Keys.idleThreshold)
        isStrictModeEnabled = UserDefaults.standard.bool(forKey: Keys.isStrictModeEnabled)
        areNotificationsEnabled = UserDefaults.standard.bool(forKey: Keys.areNotificationsEnabled)
        showMenuBarIcon = UserDefaults.standard.bool(forKey: Keys.showMenuBarIcon)
        isForcedEndOfWorkModeEnabled = UserDefaults.standard.bool(forKey: Keys.isForcedEndOfWorkModeEnabled)
        forcedEndOfWorkTime = UserDefaults.standard.double(forKey: Keys.forcedEndOfWorkTime)
        shortBreaksBeforeLongBreak = UserDefaults.standard.integer(forKey: Keys.shortBreaksBeforeLongBreak)

        isInitializing = false
    }

    func save() {
        UserDefaults.standard.set(shortBreakInterval, forKey: Keys.shortBreakInterval)
        UserDefaults.standard.set(longBreakInterval, forKey: Keys.longBreakInterval)
        UserDefaults.standard.set(shortBreakDuration, forKey: Keys.shortBreakDuration)
        UserDefaults.standard.set(longBreakDuration, forKey: Keys.longBreakDuration)
        UserDefaults.standard.set(themeName, forKey: Keys.themeName)
        UserDefaults.standard.set(soundName, forKey: Keys.soundName)
        UserDefaults.standard.set(idleThreshold, forKey: Keys.idleThreshold)
        UserDefaults.standard.set(isStrictModeEnabled, forKey: Keys.isStrictModeEnabled)
        UserDefaults.standard.set(areNotificationsEnabled, forKey: Keys.areNotificationsEnabled)
        UserDefaults.standard.set(showMenuBarIcon, forKey: Keys.showMenuBarIcon)
        UserDefaults.standard.set(isForcedEndOfWorkModeEnabled, forKey: Keys.isForcedEndOfWorkModeEnabled)
        UserDefaults.standard.set(forcedEndOfWorkTime, forKey: Keys.forcedEndOfWorkTime)
        UserDefaults.standard.set(shortBreaksBeforeLongBreak, forKey: Keys.shortBreaksBeforeLongBreak)
    }

    func resetToDefaults() {
        shortBreakInterval = defaults[Keys.shortBreakInterval] as! TimeInterval
        longBreakInterval = defaults[Keys.longBreakInterval] as! TimeInterval
        shortBreakDuration = defaults[Keys.shortBreakDuration] as! TimeInterval
        longBreakDuration = defaults[Keys.longBreakDuration] as! TimeInterval
        themeName = defaults[Keys.themeName] as! String
        soundName = defaults[Keys.soundName] as! String
        idleThreshold = defaults[Keys.idleThreshold] as! TimeInterval
        isStrictModeEnabled = defaults[Keys.isStrictModeEnabled] as! Bool
        areNotificationsEnabled = defaults[Keys.areNotificationsEnabled] as! Bool
        showMenuBarIcon = defaults[Keys.showMenuBarIcon] as! Bool
        isForcedEndOfWorkModeEnabled = defaults[Keys.isForcedEndOfWorkModeEnabled] as! Bool
        forcedEndOfWorkTime = defaults[Keys.forcedEndOfWorkTime] as! TimeInterval
        shortBreaksBeforeLongBreak = defaults[Keys.shortBreaksBeforeLongBreak] as! Int
    }
}
