import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioSession()
    }
    
    enum SoundType: String, CaseIterable {
        case moodSelected = "mood_select"
        case moodSaved = "mood_save"
        case buttonTap = "button_tap"
        case notification = "notification"
        case success = "success"
        case error = "error"
        
        var filename: String {
            switch self {
            case .moodSelected: return "pop"
            case .moodSaved: return "success"
            case .buttonTap: return "tap"
            case .notification: return "notification"
            case .success: return "chime"
            case .error: return "error"
            }
        }
        
        var volume: Float {
            switch self {
            case .buttonTap: return 0.3
            case .error: return 0.5
            default: return 0.7
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func preloadSounds() {
        for sound in SoundType.allCases {
            loadSound(sound)
        }
    }
    
    private func loadSound(_ type: SoundType) {
        // Try multiple file extensions
        let extensions = ["mp3", "wav", "m4a", "caf"]
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: type.filename, withExtension: ext) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.volume = type.volume
                    player.prepareToPlay()
                    audioPlayers[type.rawValue] = player
                    break
                } catch {
                    print("Error loading sound \(type.filename).\(ext): \(error)")
                }
            }
        }
        
        // If no sound file found, create a system sound fallback
        if audioPlayers[type.rawValue] == nil {
            print("Warning: No sound file found for \(type.filename)")
        }
    }
    
    func playSound(_ type: SoundType) {
        // Check if sounds are enabled in user settings
        guard UserDefaults.standard.bool(forKey: "soundsEnabled") != false else { return }
        
        if let player = audioPlayers[type.rawValue] {
            player.play()
        } else {
            // Fallback to system sound
            playSystemSound(for: type)
        }
    }
    
    private func playSystemSound(for type: SoundType) {
        let soundID: SystemSoundID
        
        switch type {
        case .buttonTap, .moodSelected:
            soundID = 1104 // Tock
        case .moodSaved, .success:
            soundID = 1054 // SMS Received
        case .notification:
            soundID = 1007 // SMS Sent
        case .error:
            soundID = 1053 // Error
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

// MARK: - SwiftUI Integration
import SwiftUI

struct SoundEffect: ViewModifier {
    let sound: SoundManager.SoundType
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _ in
                SoundManager.shared.playSound(sound)
            }
    }
}

extension View {
    func soundEffect(_ sound: SoundManager.SoundType, trigger: Bool) -> some View {
        modifier(SoundEffect(sound: sound, trigger: trigger))
    }
}
