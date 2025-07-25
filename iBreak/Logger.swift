import Foundation
import OSLog

struct Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let app = OSLog(subsystem: subsystem, category: "iBreak")

    static func log(_ message: String, type: OSLogType = .debug) {
        os_log(type, log: app, "%{public}@", message)
    }
}