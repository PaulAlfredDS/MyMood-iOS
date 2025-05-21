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
                .font(.headline)
                .padding()
            Text("Current Mood Score: \(currentMoodScore)%")
                .font(.headline)
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
            let month = Calendar.current.component(.month, from: Date())
            viewModel.fetchMoodEntries(by: month)
            currentMoodScore = String(format:"%.2f", viewModel.averageMoodScore)
            currentEmoji = viewModel.getCurrentEmoji()
        }.containerRelativeFrame([.horizontal, .vertical])
            .background(Gradient(colors: [Color("BG1"), Color("BG2"),Color("BG3"), Color("BG4")]).opacity(0.6))
    }
}
    
    

#Preview {
    MoodGraphView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
