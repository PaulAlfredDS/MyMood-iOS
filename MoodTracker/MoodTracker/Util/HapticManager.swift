//
//  HapticManager.swift
//  MoodTracker
//
//  Created by Paul on 5/22/25.
//

import Foundation
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    func notification(feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(feedbackType)
    }
    
    func impact(impactStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: impactStyle)
        generator.impactOccurred()
    }
}
