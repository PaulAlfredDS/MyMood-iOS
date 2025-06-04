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
        
        enum ViewMode: Equatable {
            case create
            case edit(MoodEntry)
        }
        
        @Published var moods: [MoodEntry] = []
        
        @Published var selectedDate: Date = Date()
        @Published var selectedEmoji: String = ""
        @Published var note: String = ""
        @Published var score: Int16 = 0
        
        @Published var editingMood: MoodEntry?
        
        @Published var isSuccessfullyAdded = false
        
        @Published var isSelectedEmojiValid = false
        
        @Published var mode: ViewMode = .create
        
        private var cancellables = Set<AnyCancellable>()
        
        init(localSource: MoodDataSource, remoteSource: MoodDataSource, mode: ViewMode = .create) {
            self.localSource = localSource
            self.remoteSource = remoteSource
            self.mode = mode
            
            if case .edit(let entry) = mode {
                self.editingMood = entry
                setupForEditing()
            }
            
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
        
        func setupForEditing() {
            self.selectedEmoji = editingMood?.moodEmoji ?? ""
            self.note = editingMood?.note ?? ""
            self.selectedDate = editingMood?.date ?? Date()
            self.score = editingMood?.score ?? 0
        }
        
        private func isOnline() -> Bool {
            // Implement your network reachability check here
            return true // Placeholder for actual network check
        }
    }
}
