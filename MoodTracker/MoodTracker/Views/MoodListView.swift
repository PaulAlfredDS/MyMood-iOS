//
//  MoodListView.swift
//  MoodTracker
//
//  Created by Paul on 5/26/25.
//

import SwiftUI
import Combine

struct MoodListView: View {
    @StateObject private var viewModel = MoodListViewModel(localDataSource: LocalMoodSource.shared)
    private let month: Int
    @State private var monthName: String = ""
    
    init(month: Int = 12) {
        self.month = month
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.moods, id:\.id) { mood in
                        HStack {
//                            Text("\(mood.emoji!)")
                            Text("\(mood.score)")
//                            Text(viewModel.formattedDay(from: mood.date))
                        }
                        .font(.body)
                        .foregroundColor(Color.theme.bodyText)
                    }
                }
            }
            .navigationTitle("Mood List for \(monthName)")
        }
        .onAppear() {
            viewModel.fetchMoodEntries(by: self.month)
            monthName =  Constants.MonthHelper.getMonthName(Constants.MonthHelper.Months(rawValue: month) ?? .December)
        }
        .background(LinearGradient(colors: [Color("BG1"), Color("BG2"),Color("BG3"), Color("BG4")], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.6))
    }
}

#Preview {
    MoodListView()
}
