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
    @State var selectedMonth = Constants.MonthHelper.Months.January
    @State private var animateChart = false
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    moodSummaryCard
                    
                    if viewModel.hasEnoughData {
                        chartSection
                    } else {
                        emptyStateView
                    }
                    
                    actionButtons
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(
                LinearGradient(
                    colors: [Color("BG1"), Color("BG2"), Color("BG3"), Color("BG4")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.4)
                .ignoresSafeArea()
            )
            .navigationTitle("Mood Trends")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: navigationButtons)
        }
        .onAppear {
            let currentMonth = Calendar.current.component(.month, from: Date())
            graphSetup(month: currentMonth)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                animateChart = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            monthSelector
            
            HStack {
                Text(currentEmoji)
                    .font(.system(size: 60))
                    .scaleEffect(animateChart ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateChart)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Mood")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.subText)
                    
                    Text(Constants.MonthHelper.getMonthName(selectedMonth))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.headingText)
                }
                
                Spacer()
            }
        }
    }
    
    private var moodSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Average Score")
                        .font(.caption)
                        .foregroundColor(Color.theme.subText)
                    
                    Text("\(currentMoodScore)%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Entries")
                        .font(.caption)
                        .foregroundColor(Color.theme.subText)
                    
                    Text("\(viewModel.moodEntries.count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.headingText)
                }
            }
            
            if viewModel.hasEnoughData {
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { score in
                        let percentage = viewModel.getMoodPercentage(for: score)
                        VStack(spacing: 6) {
                            Text(MoodData.getMoodEmoji(for: score))
                                .font(.title3)
                            
                            Text("\(Int(percentage))%")
                                .font(.caption2)
                                .foregroundColor(Color.theme.bodyText)
                        }
                        .opacity(percentage > 0 ? 1.0 : 0.3)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.secondary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.theme.border.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(animateChart ? 1.0 : 0.95)
        .opacity(animateChart ? 1.0 : 0.0)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1), value: animateChart)
    }
    
    private var monthSelector: some View {
        Menu {
            ForEach(Constants.MonthHelper.Months.allCases, id: \.self) { month in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMonth = month
                        viewModel.fetchMoodEntries(by: month.rawValue)
                        viewModel.hasEnoughData(on: month.rawValue)
                        currentMoodScore = String(format:"%.2f", viewModel.averageMoodScore)
                        currentEmoji = viewModel.getCurrentEmoji()
                    }
                }) {
                    HStack {
                        Text(Constants.MonthHelper.getMonthName(month))
                        Spacer()
                        if month == selectedMonth {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.theme.primary)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(Constants.MonthHelper.getMonthName(selectedMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.headingText)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.theme.secondary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.theme.border.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Trends")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.headingText)
            
            graphView
        }
        .scaleEffect(animateChart ? 1.0 : 0.95)
        .opacity(animateChart ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateChart)
    }
    
    private var graphView: some View {
        Chart {
            ForEach(viewModel.moodEntries, id: \.id) { entry in
                if entry.id != nil {
                    LineMark(
                        x: .value("Date", entry.date ?? Date()),
                        y: .value("Mood", entry.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    .symbol(.circle)
                    .symbolSize(80)
                    
                    AreaMark(
                        x: .value("Date", entry.date ?? Date()),
                        y: .value("Mood", entry.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.theme.primary.opacity(0.3),
                                Color.theme.primary.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
        .frame(height: 280)
        .chartXAxis {
            AxisMarks(preset: .aligned) { _ in
                AxisGridLine()
                    .foregroundStyle(Color.theme.border.opacity(0.3))
                AxisTick()
                    .foregroundStyle(Color.theme.border.opacity(0.5))
                AxisValueLabel()
                    .foregroundStyle(Color.theme.bodyText)
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks(values: Array(1...5)) { value in
                AxisGridLine()
                    .foregroundStyle(Color.theme.border.opacity(0.3))
                AxisTick()
                    .foregroundStyle(Color.theme.border.opacity(0.5))
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text(MoodData.getMoodEmoji(for: intValue))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYScale(domain: 0.5...5.5)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.theme.secondary.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.theme.shadow.opacity(0.15), radius: 10, x: 0, y: 5)
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(Color.theme.disabledText)
                .opacity(0.6)
            
            VStack(spacing: 8) {
                Text("No Trends Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.headingText)
                
                Text("Add at least 5 mood entries to see your trends")
                    .font(.body)
                    .foregroundColor(Color.theme.bodyText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.secondary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.theme.border.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                )
        )
        .scaleEffect(animateChart ? 1.0 : 0.95)
        .opacity(animateChart ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateChart)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            NavigationLink(
                destination: MoodEntryView(
                    currentDate: Calendar.current.date(
                        from: DateComponents(year: currentYear, month: selectedMonth.rawValue)
                    )!
                )
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    
                    Text("Add New Mood")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color.theme.primaryButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color.theme.primary, Color.theme.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .scaleEffect(animateChart ? 1.0 : 0.95)
            .opacity(animateChart ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: animateChart)
        }
    }
    
    private var navigationButtons: some View {
        NavigationLink(destination: MoodListView(month: selectedMonth.rawValue)) {
            HStack(spacing: 6) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16, weight: .medium))
                
                Text("List")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(Color.theme.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.theme.accent.opacity(0.1))
            )
        }
    }
    
    private func graphSetup(month: Int) {
        selectedMonth = Constants.MonthHelper.Months(rawValue: month) ?? .January
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
