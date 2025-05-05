//
//  MoodGraphViewModel.swift
//  MoodTracker
//
//  Created by Paul on 4/28/25.
//

import Foundation
import SwiftUI

extension MoodGraphView {
    class MoodGraphViewModel: ObservableObject {
        @Published var moodEntries: [MoodEntry] = []
        private let localDataSource: MoodDataSource
        private var averageMoodScore: Double = 0.0
        
        init(localDataSource: MoodDataSource) {
            self.localDataSource = localDataSource
        }
        
        func fetchMoodEntries() {
            moodEntries = localDataSource.getMoodEntries()
        }
        
        func fetchMoodEntries(by month: Int) {
            moodEntries = localDataSource.getMoodsbyMonth(month)
        }
        
        func getDaysOfMonth(of date: Date) -> [String] {
            var days: [String] = []
            for _ in 1...getMaxDay(of: date)! {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMdd"
                let dateString = dateFormatter.string(from: date)
                days.append(dateString)
            }
            return days
        }
        
        private func getMaxDay(of date: Date) -> Int? {
            let calendar = Calendar.current
            let range = calendar.range(of: .day, in: .month, for: date)
            return range?.count
        }
        
        func getAveMoodScorePercentage(from moodScores: [Int]) -> Double {
            averageMoodScore = Double(moodScores.reduce(0, +)) / Double(moodScores.count)
            let percentage = (averageMoodScore / 5.0) * 100
            print("Mood Score: \(percentage)%")
            return percentage
        }
        
        func getCurrentEmoji() -> String {
            if averageMoodScore.isNaN {
                return "😡"
            }
            
            let roundedScore = Int(averageMoodScore)
            for mood in MoodData.moods {
                if mood.score == roundedScore {
                    return mood.emoji
                }
            }
            return "😡" // Default emoji if no match found
        }
        
    }
}
