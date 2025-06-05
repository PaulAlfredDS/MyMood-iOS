//
//  HapticManager.swift
//  MoodTracker
//
//  Created by Paul on 5/22/25.
//

import UIKit
import CoreHaptics
import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    private var hapticEngine: CHHapticEngine?
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        setupHapticEngine()
        prepareGenerators()
    }
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to start haptic engine: \(error)")
        }
    }
    
    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // MARK: - Simple Haptics
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard UserDefaults.standard.bool(forKey: "hapticsEnabled") != false else { return }
        
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        default:
            impactMedium.impactOccurred()
        }
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UserDefaults.standard.bool(forKey: "hapticsEnabled") != false else { return }
        notificationFeedback.notificationOccurred(type)
    }
    
    func selection() {
        guard UserDefaults.standard.bool(forKey: "hapticsEnabled") != false else { return }
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Context-Specific Haptics
    
    func moodSelected() {
        selection()
        SoundManager.shared.playSound(.moodSelected)
    }
    
    func moodSaved() {
        notification(.success)
        SoundManager.shared.playSound(.moodSaved)
    }
    
    func buttonTapped() {
        impact(.light)
        SoundManager.shared.playSound(.buttonTap)
    }
    
    func error() {
        notification(.error)
        SoundManager.shared.playSound(.error)
    }
    
    // MARK: - Custom Haptic Patterns
    
    func playCustomPattern(_ pattern: HapticPattern) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              UserDefaults.standard.bool(forKey: "hapticsEnabled") != false else { return }
        
        do {
            let pattern = try createHapticPattern(pattern)
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic: \(error)")
        }
    }
    
    enum HapticPattern {
        case success
        case warning
        case failure
        case heartbeat
    }
    
    private func createHapticPattern(_ pattern: HapticPattern) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        
        switch pattern {
        case .success:
            events = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ], relativeTime: 0.1)
            ]
            
        case .warning:
            events = [
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ], relativeTime: 0, duration: 0.5)
            ]
            
        case .failure:
            for i in 0..<3 {
                events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ], relativeTime: TimeInterval(i) * 0.1))
            }
            
        case .heartbeat:
            events = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ], relativeTime: 0.2)
            ]
        }
        
        return try CHHapticPattern(events: events, parameters: [])
    }
}

// MARK: - SwiftUI Integration

struct HapticFeedback: ViewModifier {
    let type: HapticType
    let trigger: Bool
    
    enum HapticType {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case selection
        case custom(HapticManager.HapticPattern)
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _ in
                switch type {
                case .impact(let style):
                    HapticManager.shared.impact(style)
                case .notification(let type):
                    HapticManager.shared.notification(type)
                case .selection:
                    HapticManager.shared.selection()
                case .custom(let pattern):
                    HapticManager.shared.playCustomPattern(pattern)
                }
            }
    }
}

extension View {
    func hapticFeedback(_ type: HapticFeedback.HapticType, trigger: Bool) -> some View {
        modifier(HapticFeedback(type: type, trigger: trigger))
    }
    
    func onTapWithFeedback(action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            HapticManager.shared.buttonTapped()
            action()
        }
    }
}
