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
        Keys.forcedEndOfWorkTime: 18 * 3600 // Default 18:00 (6 PM) in seconds from midnight
    ]

    @Published var shortBreakInterval: TimeInterval
    @Published var longBreakInterval: TimeInterval
    @Published var shortBreakDuration: TimeInterval
    @Published var longBreakDuration: TimeInterval
    @Published var themeName: String
    @Published var soundName: String
    @Published var idleThreshold: TimeInterval
    @Published var isStrictModeEnabled: Bool
    @Published var areNotificationsEnabled: Bool
    @Published var showMenuBarIcon: Bool
    @Published var isForcedEndOfWorkModeEnabled: Bool
    @Published var forcedEndOfWorkTime: TimeInterval

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
        save()
    }
}
