//
//  MoodTrackerApp.swift
//  MoodTracker
//
//  Created by Paul on 4/7/25.
//

import SwiftUI

@main
struct MoodTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MoodEntryView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
