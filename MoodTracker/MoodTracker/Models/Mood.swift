//
//  Mood.swift
//  MoodTracker
//
//  Created by Paul on 4/28/25.
//
import Foundation

struct Mood: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
    let score: Int
}
