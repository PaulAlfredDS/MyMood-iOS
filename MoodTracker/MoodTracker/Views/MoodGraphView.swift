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
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        NavigationView {
            VStack {
                monthMenu
                
                Text(currentEmoji)
                    .font(.largeTitle)
                    .padding()
                
                ZStack {
                    
                    if viewModel.hasEnoughData {
                        VStack {
                            Text("Current Mood Score: \(currentMoodScore)%")
                                .font(.headline)
                                .foregroundColor(Color.theme.bodyText)
                                .padding()
                            
                            graphView
                        }
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color.theme.disabledText)
                                .opacity(0.5)
                                .frame(height: 300)
                                .cornerRadius(16)
                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                            Text("Add atleast 5 mood logs to see the graph")
                                .foregroundColor(Color.theme.bodyText)
                                .font(.headline)
                            
                        }
                    }
                }
                
                NavigationLink(
                    destination: MoodEntryView(
                        currentDate: Calendar.current.date(
                            from: DateComponents(year: currentYear, month:selectedMonth.rawValue)
                        )!
                    )
                ) {
                    Text("Add Mood View")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight:50)
                        .background(Color.theme.primary)
                        .foregroundColor(Color.theme.primaryButtonText)
                        .cornerRadius(20).padding()
                    
                }
                
                
            }.onAppear {
                let currentMonth = Calendar.current.component(.month, from: Date())
                grpahSetup(month: currentMonth)
            }.containerRelativeFrame([.horizontal, .vertical])
                .background(LinearGradient(colors: [Color("BG1"), Color("BG2"),Color("BG3"), Color("BG4")], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.6))
        }
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
    
    var graphView: some View {
        Chart {
            ForEach(viewModel.moodEntries, id: \.id) { entry in
                if entry.id != nil {
                    LineMark(x: .value("Days", entry.date ?? Date()), y: .value("Score", entry.score))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.theme.primary)
                        .symbol(Circle())
                }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned) { _ in
                AxisGridLine().foregroundStyle(Color.theme.secondary)
                AxisTick()
                AxisValueLabel().foregroundStyle(Color.theme.bodyText)
            }
        }
        .chartYAxis {
            AxisMarks(values: Array(1...5)) {
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
                            Color.theme.accent,
                            Color("BackgroundGradient1")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .padding().frame(height: 300)
    }
    
    private func grpahSetup(month: Int) {
        selectedMonth = MoodGraphView.MoodGraphViewModel.Months(rawValue: month) ?? .January
        viewModel.fetchMoodEntries(by: month)
        viewModel.hasEnoughData(on: month)
        currentMoodScore = String(format:"%.2f", viewModel.averageMoodScore)
        currentEmoji = viewModel.getCurrentEmoji()
    }
}
    
    

#Preview {
    MoodGraphView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
