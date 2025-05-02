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
            // Check if mood already exists
            if localSource.doesMoodExist(mood.date!) {
                print("Mood already exists for this date.")
                return true
            }
                
            
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

