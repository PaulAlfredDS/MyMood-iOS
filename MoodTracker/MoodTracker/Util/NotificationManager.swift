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
}
