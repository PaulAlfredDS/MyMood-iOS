//
//  MoodSource.swift
//  MoodTracker
//
//  Created by Paul on 4/22/25.
//

import Foundation
import Combine


protocol MoodDataSource {
    func addMood(_ mood: MoodEntry)
    func deleteMood(_ mood: MoodEntry)
    func getMoodEntries() -> [MoodEntry]
    func getMoodEntry(by id: UUID) -> MoodEntry?
    func getMoodsbyMonth(_ month: Int) -> [MoodEntry]
    func updateMood(_ mood: MoodEntry)
    func saveMood() -> AnyPublisher<Void, Error>
    func doesMoodExist(_ date: Date) -> Bool
}
