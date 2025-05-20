//
//  CoreDataManager.swift
//  MoodTracker
//
//  Created by Paul on 4/23/25.
//

import CoreData
import Combine

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
    
    func saveContextPublisher() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.viewContext.perform {
                do {
                    if self.viewContext.hasChanges {
                        try self.viewContext.save()
                    }
                    promise(.success(())) // completes successfully
                } catch {
                    promise(.failure(error)) // completes with error
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
