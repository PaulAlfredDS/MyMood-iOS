//
//  MoodViewModel.swift
//  MoodTracker
//
//  Created by Paul on 4/7/25.
//

import Foundation
import SwiftUI
import CoreData


extension MoodEntryView {
    class MoodViewModel: ObservableObject {
        private let localSource: MoodDataSource
        private let remoteSource: MoodDataSource

        @Published var moods: [MoodEntry] = []

        init(localSource: MoodDataSource, remoteSource: MoodDataSource) {
            self.localSource = localSource
            self.remoteSource = remoteSource
        }

        func addMood(_ mood: MoodEntry) -> Bool{
            // Safely unwrap mood.date
//            guard let moodDate = mood.date else {
//                print("Mood date is nil. Cannot add mood entry.")
//                return false
//            }
//    
//            //Check if date is unique
//            if localSource.doesMoodExist(mood.date!) {
//                return true
//            }

            localSource.addMood(mood)
            moods.append(mood)

            // Sync with remote if online
            if isOnline() {
                remoteSource.addMood(mood)
            }
            syncMoods()
            return false
        }

        func syncMoods() {
            localSource.saveMood()
            if NetworkUtils.shared.isConnected {
                remoteSource.saveMood()
            }
        }

        private func isOnline() -> Bool {
            // Implement your network reachability check here
            return true // Placeholder for actual network check
        }
    }
}

