//
//  MoodData.swift
//  MoodTracker
//
//  Created by Paul on 4/28/25.
//

import Foundation

struct MoodData {
    static let moods: [Mood] = [
        Mood(emoji: "🥳", label: "Very Happy", score: 5),
        Mood(emoji: "😄", label: "Happy", score: 4),
        Mood(emoji: "😐", label: "Neutral", score: 3),
        Mood(emoji: "😢", label: "Sad", score: 2),
        Mood(emoji: "😭", label: "Very Sad", score: 1)
    ]
}

