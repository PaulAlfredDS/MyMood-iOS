//
//  MoodListViewModel.swift
//  MoodTracker
//
//  Created by Paul on 5/26/25.
//

import Foundation


class MoodListViewModel: ObservableObject {
    
    private var localDataSource: MoodDataSource
    
    @Published var moodEntries: [MoodEntry] = []
    
    
    init(localDataSource: MoodDataSource) {
        self.localDataSource = localDataSource
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        localDataSource.deleteMood(entry)
        moodEntries = localDataSource.getMoodEntries()
    }
    
    func fetchMoodEntries() {
        moodEntries = localDataSource.getMoodEntries()
    }
}
