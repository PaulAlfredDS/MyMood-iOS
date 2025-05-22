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
    @State var selectedMonth = MoodGraphView.MoodGraphViewModel.Months.January

    fileprivate func grpahSetup(month: Int) {
        selectedMonth = MoodGraphView.MoodGraphViewModel.Months(rawValue: month) ?? .January
        viewModel.fetchMoodEntries(by: month)
        viewModel.hasEnoughData(on: month)
        currentMoodScore = String(format:"%.2f", viewModel.averageMoodScore)
        currentEmoji = viewModel.getCurrentEmoji()
    }
    
    var body: some View {
        VStack {
            monthMenu
                
            Text(currentEmoji)
                .font(.largeTitle)
                .padding()
            Text("Current Mood Score: \(currentMoodScore)%")
                .font(.headline)
                .foregroundColor(Color.theme.bodyText)
                .padding()
            ZStack {
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
                ZStack {
                    Rectangle()
                        .fill(Color.theme.disabledText)
                        .opacity(0.95)
                        .frame(height: 300)
                        .cornerRadius(16)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                    Text("Add atleast 5 mood logs to see the graph")
                        .foregroundColor(Color.theme.bodyText)
                        .font(.headline)

                }
            }
             
        }.onAppear {
            let currentMonth = Calendar.current.component(.month, from: Date())
            grpahSetup(month: currentMonth)
        }.containerRelativeFrame([.horizontal, .vertical])
            .background(LinearGradient(colors: [Color("BG1"), Color("BG2"),Color("BG3"), Color("BG4")], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.6))
    }
    
    var monthMenu: some View {
        Menu(viewModel.getMonthName(selectedMonth) + " ⬇️") {
            ForEach(MoodGraphView.MoodGraphViewModel.Months.allCases, id: \.self) { month in
                Button(viewModel.getMonthName(month)) {
                    selectedMonth = month
                    viewModel.fetchMoodEntries(by: month.rawValue)
                    viewModel.hasEnoughData(on: month.rawValue)
                }
            }
        }
        .font(.title)
        .foregroundColor(Color.theme.headingText)
        .padding()
    }
}
    
    

#Preview {
    MoodGraphView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
