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
        @Published var averageMoodScore: Double = 0.0
        @Published var hasEnoughData: Bool = false
            
        
        init(localDataSource: MoodDataSource) {
            self.localDataSource = localDataSource
        }
        
        func fetchMoodEntries() {
            moodEntries = localDataSource.getMoodEntries()
            averageMoodScore = getAveMoodScorePercentage(from: moodEntries.map { Int($0.score) })
            getCurrentEmoji()
        }
        
        func fetchMoodEntries(by month: Int) {
            moodEntries = localDataSource.getMoodsbyMonth(month)
            averageMoodScore = getAveMoodScorePercentage(from: moodEntries.map { Int($0.score) })
            getCurrentEmoji()
            moodEntries = moodEntries.sorted { $0.date! < $1.date! }
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
                return "😌"
            }
            
            let roundedScore = Int(averageMoodScore)
            switch roundedScore {
            case 0...20:
                return MoodData.moods[4].emoji
            case 21...40:
                return MoodData.moods[3].emoji
            case 41...60:
                return MoodData.moods[2].emoji
            case 61...80:
                return MoodData.moods[1].emoji
            case 81...100:
                return MoodData.moods[0].emoji
            default:
                break
                
            }
            return "😌" // Default emoji if no match found
        }
        
        func hasEnoughData(on month: Int) {
            hasEnoughData = localDataSource.getMoodsbyMonth(month).count > 4
        }
        
    }
}
