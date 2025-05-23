//
//  MoodViewModel.swift
//  MoodTracker
//
//  Created by Paul on 4/7/25.
//

import Foundation
import SwiftUI
import CoreData
import Combine


extension MoodEntryView {
    class MoodEntryViewModel: ObservableObject {
        private let localSource: MoodDataSource
        private let remoteSource: MoodDataSource
        
        @Published var moods: [MoodEntry] = []
        
        @Published var selectedDate: Date = Date()
        @Published var selectedEmoji: String = ""
        @Published var note: String = ""
        @Published var score: Int16 = 0
        
        @Published var isSuccessfullyAdded = false
        
        @Published var isSelectedEmojiValid = false
        
        private var cancellables = Set<AnyCancellable>()
        
        init(localSource: MoodDataSource, remoteSource: MoodDataSource) {
            self.localSource = localSource
            self.remoteSource = remoteSource
            
            Publishers.CombineLatest($selectedEmoji, $note)
                .map { emoji, note  in
                    !emoji.isEmpty && !note.isEmpty
                }
                .removeDuplicates()
                .assign(to: &$isSelectedEmojiValid)
        }
        
        func addMood(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
            guard !selectedEmoji.isEmpty, !note.isEmpty else { return }
            
            let newMood = MoodEntry(context: CoreDataManager.shared.persistentContainer.viewContext)
            newMood.id = UUID()
            newMood.moodEmoji = selectedEmoji
            newMood.note = note
            newMood.date = selectedDate
            newMood.score = score
            
            
            // Check if mood already exists
            if localSource.doesMoodExist(newMood.date!) {
                print("Mood already exists for this date.")
                onFailure(NSError(domain: "MoodEntryError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mood already exists for this date."]))
                return
            }
            
            
            localSource.addMood(newMood)
            moods.append(newMood)
            
            // Sync with remote if online
            if isOnline() {
                remoteSource.addMood(newMood)
            }
            localSource.saveMood().receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            print("Mood saved successfully")
                            onSuccess()
                        break
                            
                        case .failure(let error):
                            print("Error saving mood: \(error)")
                            onFailure(error)
                        break
                    }
                }, receiveValue: { [weak self] in
                    self?.isSuccessfullyAdded = true
                })
                .store(in: &cancellables)
        }
        
//        func syncMoods() {
//            localSource.saveMood().receive(on: RunLoop.main)
//                .sink(receiveCompletion: { completion in
//                    switch completion {
//                    case .finished:
//                        print("Mood saved successfully")
//                    case .failure(let error):
//                        print("Error saving mood: \(error)")
//                    }
//                }, receiveValue: { [weak self] in
//                    self?.isSuccessfullyAdded = true
//                })
//                .store(in: &cancellables)
//            if NetworkUtils.shared.isConnected {
//                remoteSource.saveMood()
//            }
//        }
        
        private func isOnline() -> Bool {
            // Implement your network reachability check here
            return true // Placeholder for actual network check
        }
    }
}
