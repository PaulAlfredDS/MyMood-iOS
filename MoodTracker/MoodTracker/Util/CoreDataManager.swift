//
//  CoreDataManager.swift
//  MoodTracker
//
//  Created by Paul on 4/23/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    // Shortcut to main context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "MoodTracker") // <-- Replace with your .xcdatamodeld name
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("❌ Failed to load Core Data stack: \(error)")
            }
        }
        let storeURL = self.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url
        print("📂 Core Data SQLite path: \(storeURL?.path ?? "Not found")")
    }

    // Helper to save context safely
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("⚠️ Error saving Core Data context: \(error.localizedDescription)")
            }
        }
    }
}
