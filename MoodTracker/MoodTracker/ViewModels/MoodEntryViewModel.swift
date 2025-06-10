//
//  MoodEntryViewModel.swift
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
            case edit(MoodEntry = MoodEntry(context: CoreDataManager.shared.persistentContainer.viewContext))
            
            var isEdit: Bool {
                if case .edit = self { return true }
                return false
            }
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
        @Published var errorMessage: String?
        @Published var isLoading = false
        
        private var cancellables = Set<AnyCancellable>()
        private var originalMoodData: (emoji: String, note: String, date: Date, score: Int16)?
        
        init(localSource: MoodDataSource, remoteSource: MoodDataSource, mode: ViewMode = .create, selectedDate: Date = Date()) {
            self.localSource = localSource
            self.remoteSource = remoteSource
            self.mode = mode
            
            if mode == .create {
                self.selectedDate = selectedDate
            }
            
            setupValidation()
            
            if case .edit(let entry) = mode {
                self.editingMood = entry
                setupForEditing(entry)
            }
        }
        
        private func setupValidation() {
            Publishers.CombineLatest($selectedEmoji, $note)
                .map { emoji, note in
                    !emoji.isEmpty && !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                .removeDuplicates()
                .assign(to: &$isSelectedEmojiValid)
        }
        
        private func setupForEditing(_ mood: MoodEntry) {
            self.selectedEmoji = mood.moodEmoji ?? ""
            self.note = mood.note ?? ""
            self.selectedDate = mood.date ?? Date()
            self.score = mood.score
            
            // Store original values for comparison
            self.originalMoodData = (
                emoji: mood.moodEmoji ?? "",
                note: mood.note ?? "",
                date: mood.date ?? Date(),
                score: mood.score
            )
        }
        
        func addMood(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
            guard !selectedEmoji.isEmpty, !note.isEmpty else { return }
            
            isLoading = true
            errorMessage = nil
            
            // Check if mood already exists for this date
            if localSource.doesMoodExist(selectedDate) {
                let error = NSError(
                    domain: "MoodEntryError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "A mood entry already exists for this date."]
                )
                errorMessage = "A mood entry already exists for this date."
                isLoading = false
                onFailure(error)
                return
            }
            
            let newMood = MoodEntry(context: CoreDataManager.shared.persistentContainer.viewContext)
            newMood.id = UUID()
            newMood.moodEmoji = selectedEmoji
            newMood.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            newMood.date = selectedDate
            newMood.score = score
            
            localSource.addMood(newMood)
            
            // Sync with remote if online
            if isOnline() {
                Task {
                    await syncToRemote(newMood)
                }
            }
            
            localSource.saveMood()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        switch completion {
                        case .finished:
                            print("Mood saved successfully")
                            onSuccess()
                        case .failure(let error):
                            print("Error saving mood: \(error)")
                            self?.errorMessage = error.localizedDescription
                            onFailure(error)
                        }
                    },
                    receiveValue: { [weak self] in
                        self?.isSuccessfullyAdded = true
                    }
                )
                .store(in: &cancellables)
        }
        
        func updateMood(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
            guard case .edit(let mood) = mode else { return }
            guard !selectedEmoji.isEmpty, !note.isEmpty else { return }
            
            isLoading = true
            errorMessage = nil
            
            // Check if data has actually changed
            if let original = originalMoodData {
                let hasChanges = original.emoji != selectedEmoji ||
                               original.note != note ||
                               original.score != score
                
                if !hasChanges {
                    // No changes made, just call success
                    isLoading = false
                    onSuccess()
                    return
                }
            }
            
            // Update the mood entry
            mood.moodEmoji = selectedEmoji
            mood.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            mood.score = score
            
            // Note: We don't update the date in edit mode
            
            // Sync with remote if online
            if isOnline() {
                Task {
                    await syncToRemote(mood)
                }
            }
            
            localSource.saveMood()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        switch completion {
                        case .finished:
                            print("Mood updated successfully")
                            onSuccess()
                        case .failure(let error):
                            print("Error updating mood: \(error)")
                            self?.errorMessage = error.localizedDescription
                            onFailure(error)
                        }
                    },
                    receiveValue: { [weak self] in
                        self?.isSuccessfullyAdded = true
                    }
                )
                .store(in: &cancellables)
        }
        
        private func syncToRemote(_ mood: MoodEntry) async {
            do {
                // Implement your Firebase sync here
                remoteSource.addMood(mood)
            } catch {
                print("Failed to sync to remote: \(error)")
                // Don't fail the local save if remote sync fails
            }
        }
        
        private func isOnline() -> Bool {
            // Implement your network reachability check here
            // For now, return true as placeholder
            return true
        }
        
        func deleteMood(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
            guard case .edit(let mood) = mode else { return }
            
            isLoading = true
            errorMessage = nil
            
            localSource.deleteMood(mood)
            
            // Sync deletion with remote if online
            if isOnline() {
                remoteSource.deleteMood(mood)
            }
            
            localSource.saveMood()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        switch completion {
                        case .finished:
                            print("Mood deleted successfully")
                            onSuccess()
                        case .failure(let error):
                            print("Error deleting mood: \(error)")
                            self?.errorMessage = error.localizedDescription
                            onFailure(error)
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
    }
}

