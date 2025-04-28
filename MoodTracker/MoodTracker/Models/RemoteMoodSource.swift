//
//  RemoteMoodSource.swift
//  MoodTracker
//
//  Created by Paul on 4/22/25.
//

import Foundation

class RemoteMoodSource: MoodDataSource {
    func addMood(_ mood: MoodEntry) {
    }
    
    func deleteMood(_ mood: MoodEntry) {
        
    }
    
    func getMoodEntries() -> [MoodEntry] {
        return []
    }
    
    func getMoodEntry(by id: UUID) -> MoodEntry? {
        return nil
    }
    
    func getMoodsbyMonth(_ month: Int) -> [MoodEntry] {
        return []
    }
    
    func updateMood(_ mood: MoodEntry) {
    
    }
    
    func saveMood() {

    }
    
    func doesMoodExist(_ date: Date) -> Bool {
        return false
    }
}
