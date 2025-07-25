import Foundation

// Defines the specific, non-linear time steps for our settings sliders.
struct TimeIntervals {
    static let workIntervals: [TimeInterval] = [
        10 * 60, 15 * 60, 20 * 60, 25 * 60, 30 * 60, 40 * 60, 50 * 60, 60 * 60
    ]

    static let smallBreakDurations: [TimeInterval] = [
        15, 30, 45, 60, 90, 120, 180, 240, 300
    ]

    static let bigBreakDurations: [TimeInterval] = [
        5 * 60, 10 * 60, 15 * 60, 20 * 60, 25 * 60, 30 * 60
    ]

    static let idleThresholdIntervals: [TimeInterval] = [
        60, 120, 180, 240, 300, 420, 600, 900, 1200, 1800 // 15s to 30min
    ]
}
