import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("NOTIFICATION PERMISSION ERROR: \(error.localizedDescription)")
                    return
                }
                
                if granted {
                    print("Notification permission granted.")
                } else {
                    print("Notification permission denied.")
                }
            }
        }
    }

    func scheduleNotification(timeRemaining: TimeInterval, breakType: String) {
        let content = UNMutableNotificationContent()
        content.title = "iBreak Reminder"
        content.sound = .default

        let notificationTime: TimeInterval
        if breakType == "short" {
            notificationTime = 30
            content.body = "Your short break starts in 30 seconds."
        } else {
            notificationTime = 60
            content.body = "Your long break starts in 1 minute."
        }

        // Ensure we don't schedule a notification for the past
        let triggerTime = timeRemaining - notificationTime
        guard triggerTime > 0 else {
            print("NotificationManager: Could not schedule notification: Trigger time (\(triggerTime)) is in the past.")
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("NotificationManager: ERROR SCHEDULING NOTIFICATION: \(error.localizedDescription)")
                } else {
                    print("NotificationManager: Notification scheduled successfully for \(breakType) break, will fire in \(Int(triggerTime)) seconds.")
                }
            }
        }
    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("NotificationManager: All pending notifications cancelled.")
    }
}
