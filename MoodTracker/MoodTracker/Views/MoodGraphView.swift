//
//  MoodGraph.swift
//  MoodTracker
//
//  Created by Paul on 4/28/25.
//

import Foundation
import CoreData
import SwiftUI
import Charts
struct MoodGraphView: View {
    @StateObject var viewModel = MoodGraphViewModel(localDataSource: LocalMoodSource.shared)
    
    @State var currentMoodScore: String = ""
    @State var currentEmoji: String = ""

    var body: some View {
        VStack {
            Text(currentEmoji)
                .font(.largeTitle)
                .padding()
            Text("Current Mood Score: \(currentMoodScore)%")
                .font(.headline)
                .padding()
                .foregroundColor(.white)
                .padding()
            Text("Mood Graph")
                .font(.largeTitle)
                .padding()
            Chart {
                ForEach(viewModel.moodEntries, id: \.id) { entry in
                    if entry.id != nil {
                        LineMark(x: .value("Days", entry.date ?? Date()), y: .value("Score", entry.score))
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color.blue)
                            .symbol(Circle())
                    }
                }
            }.frame(height: 300)
             .padding()
        }.onAppear {
            viewModel.fetchMoodEntries()
            let moodScores : [Int] = viewModel.moodEntries.map { Int($0.score) }
            let averageMoodScore = viewModel.getAveMoodScorePercentage(from: moodScores)
            currentEmoji = viewModel.getCurrentEmoji()
            currentMoodScore = String(format:"%.2f", averageMoodScore)
        }.containerRelativeFrame([.horizontal, .vertical])
            .background(Gradient(colors: [.blue,.orange, .purple]).opacity(0.6))
    }
}
    
    

#Preview {
    MoodGraphView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
