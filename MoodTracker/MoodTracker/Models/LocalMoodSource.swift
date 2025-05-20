//
//  LocalMoodSource.swift
//  MoodTracker
//
//  Created by Paul on 4/22/25.
//

import Foundation
import CoreData
import Combine

class LocalMoodSource: MoodDataSource {
    static let shared = LocalMoodSource()
    private init() {}
    private var context = CoreDataManager.shared.persistentContainer.viewContext
    
    func addMood(_ mood: MoodEntry) {
        saveMood()
    }
    
    func deleteMood(_ mood: MoodEntry) {
        context.delete(mood)
    }
    
    func getMoodEntries() -> [MoodEntry] {
        let fetchRequest: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            let entries = try context.fetch(fetchRequest)
             print("Fetched mood entries: \(entries)")
            return entries
        } catch {
            print("Failed to fetch mood entries: \(error)")
            return []
        }
    }
    
    func getMoodEntry(by id: UUID) -> MoodEntry? {
        let fetchRequest: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch mood entry by ID: \(error)")
            return nil
        }
    }
    
    func updateMood(_ mood: MoodEntry) {
        guard let moodId = mood.id else {
            print("Mood ID is nil. Cannot update mood entry.")
            return
        }
        
        let fetchRequest: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", moodId as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingMood = results.first {
                existingMood.moodEmoji = mood.moodEmoji
                existingMood.date = mood.date
                existingMood.note = mood.note
                saveMood()
            }
        } catch {
            print("Failed to update mood entry: \(error)")
        }
    }
    
    func saveMood() -> AnyPublisher<Void, Error> {
        return CoreDataManager.shared.saveContextPublisher()
    }
    
    func getMoodsbyMonth(_ month: Int) -> [MoodEntry] {
        let fetchRequest: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: Date()), month: month, day: 1))!
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch moods by month: \(error)")
            return []
        }
    }
    
    func doesMoodExist(_ date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) else {
            return false
        }

        let fetchRequest: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.includesPendingChanges = false

        do {
            let entries = try context.fetch(fetchRequest)
            print("Mood entries for date \(date): \(entries)")
            print("Fetched mood entries between \(startOfDay) and \(endOfDay): \(entries.count)")
            return entries.count > 0
        } catch {
            print("Fetch error: \(error)")
            return false
        }
    }

}
