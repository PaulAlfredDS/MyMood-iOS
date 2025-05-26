//
//  MoodListViewModel.swift
//  MoodTracker
//
//  Created by Paul on 5/26/25.
//

import Foundation
import Combine


extension MoodListView {
    class MoodListViewModel: ObservableObject {
        
        private var localDataSource: MoodDataSource
        
        @Published var moods: [MoodEntry] = []
        
        private var cancellables = Set<AnyCancellable>()

        
        init(localDataSource: MoodDataSource) {
            self.localDataSource = localDataSource
        }
        
        func deleteMoodEntry(_ entry: MoodEntry) {
            localDataSource.deleteMood(entry)
            moods = localDataSource.getMoodEntries()
        }
        
        func fetchMoodEntries(by month: Int) {
            localDataSource.getMoodsbyMonth(month)
                .publisher
                .compactMap { mood in
                    guard mood.moodEmoji != nil else {
                        return nil
                    }
                    return mood
                }
                .collect()
                .map { moods in
                    moods.sorted { $0.date! > $1.date! }
                }
                .receive(on: RunLoop.main)
                .sink { [weak self] sortedMoods in
                    self?.moods = sortedMoods
                }
                .store(in: &cancellables)
        }

        
        func formattedDay(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d EEE" // e.g. 21 Tue
            return formatter.string(from: date)
        }

    }
}
