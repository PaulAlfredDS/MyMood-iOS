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
        
        enum Months: Int, CaseIterable {
            case January = 1, February = 2, March = 3, April = 4, May = 5, June = 6, July = 7, August = 8, September = 9, October = 10, November = 11, December = 12
        }
        
        func getMonthName(_ month: Months) -> String {
            switch month {
            case .January:
                return "January"
            case .February:
                return "February"
            case .March:
                return "March"
            case .April:
                return "April"
            case .May:
                return "May"
            case .June:
                return "June"
            case .July:
                return "July"
            case .August:
                return "August"
            case .September:
                return "September"
            case .October:
                return "October"
            case .November:
                return "November"
            case .December:
                return "December"
            }
        }
            
        
        init(localDataSource: MoodDataSource) {
            self.localDataSource = localDataSource
        }
        
        func fetchMoodEntries() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.moodEntries = self.localDataSource.getMoodEntries()
                self.averageMoodScore = self.getAveMoodScorePercentage(from: self.moodEntries.map { Int($0.score) })
                self.getCurrentEmoji()
            }
        }
        
        func fetchMoodEntries(by month: Int) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.moodEntries = self.localDataSource.getMoodsbyMonth(month)
                self.averageMoodScore = self.getAveMoodScorePercentage(from: self.moodEntries.map { Int($0.score) })
                self.getCurrentEmoji()
                self.moodEntries = self.moodEntries.sorted { $0.date! < $1.date! }
            }
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
