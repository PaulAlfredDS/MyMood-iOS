//
//  Constants.swift
//  MoodTracker
//
//  Created by Paul on 5/6/25.
//

import Foundation

struct Constants {
    struct FIREBASE {
        static let clientID = "1014680847684-pie95ii3kah99a66gha22pr35joad11b.apps.googleusercontent.com"
    }
    
    struct MonthHelper {
        enum Months: Int, CaseIterable {
            case January = 1, February = 2, March = 3, April = 4, May = 5, June = 6, July = 7, August = 8, September = 9, October = 10, November = 11, December = 12
        }
        
        static func getMonthName(_ month: Months) -> String {
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
    }
}
