//
//  NotificationManager.swift
//  MoodTracker
//
//  Created by Paul on 5/20/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager() // Singleton instance
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) {  (success, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("SUCCESS")
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Mood Tracker Reminder"
        content.subtitle = "Daily Mood Check-In"
        content.body = "Don't forget to log your mood today!"
        content.sound = .default
        content.badge = 1
        
        // Configure the trigger for a daily notification at 7 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
