//
//  SoundManager.swift
//  MoodTracker
//
//  Created by Paul on 5/22/25.
//

import AudioToolbox


class SoundManager {
    static let shared = SoundManager()
    
    func playSavedSound() {
        AudioServicesPlaySystemSound(1057)
    }
}
