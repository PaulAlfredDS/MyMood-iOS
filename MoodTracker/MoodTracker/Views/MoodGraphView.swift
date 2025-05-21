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
                .foregroundColor(Color.theme.bodyText)
                .padding()
            Chart {
                ForEach(viewModel.moodEntries, id: \.id) { entry in
                    if entry.id != nil {
                        LineMark(x: .value("Days", entry.date ?? Date()), y: .value("Score", entry.score))
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color.theme.primary)
                            .symbol(Circle())
                    }
                }
            }        .chartXAxis {
                AxisMarks(preset: .aligned) { _ in
                    AxisGridLine().foregroundStyle(Color.theme.secondary) // custom grid color
                    AxisTick()
                    AxisValueLabel().foregroundStyle(Color.theme.bodyText)
                }
            }
            .chartYAxis {
                AxisMarks() {
                    AxisGridLine().foregroundStyle(Color.theme.secondary)
                    AxisTick()
                    AxisValueLabel().foregroundStyle(Color.theme.bodyText)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("BackgroundGradient1"),
                                Color("BackgroundGradient4")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .padding().frame(height: 300)
             
        }.onAppear {
            let month = Calendar.current.component(.month, from: Date())
            viewModel.fetchMoodEntries(by: month)
            currentMoodScore = String(format:"%.2f", viewModel.averageMoodScore)
            currentEmoji = viewModel.getCurrentEmoji()
        }.containerRelativeFrame([.horizontal, .vertical])
            .background(LinearGradient(colors: [Color("BG1"), Color("BG2"),Color("BG3"), Color("BG4")], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.6))
    }
}
    
    

#Preview {
    MoodGraphView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
