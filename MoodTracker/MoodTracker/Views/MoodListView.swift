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
    @State private var showingEditView = false
    @State private var selectedMoodForEdit: MoodEntry?
    
    init(month: Int = 12) {
        self.month = month
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.moods, id: \.id) { mood in
                        MoodRowView(
                            mood: mood,
                            formattedDay: viewModel.formattedDay(from: mood.date ?? Date()),
                            onEdit: { editMoodEntry(mood) },
                            onDelete: { deleteMoodEntry(mood) }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear(perform: setupView)
        .background(backgroundGradient)
        .sheet(item: $selectedMoodForEdit) { mood in
            MoodEntryView(viewMode: .edit(mood))
        }
        .onChange(of: selectedMoodForEdit) { _ in
            if selectedMoodForEdit == nil {
                viewModel.fetchMoodEntries(by: month)
            }
        }
    }
}

// MARK: - Private Computed Properties
private extension MoodListView {
    var navigationTitle: String {
        "\(monthName) Moods"
    }
    
    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color("BG1"), Color("BG2"), Color("BG3"), Color("BG4")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.6)
        .ignoresSafeArea()
    }
}

// MARK: - Private Methods
private extension MoodListView {
    func setupView() {
        viewModel.fetchMoodEntries(by: month)
        monthName = Constants.MonthHelper.getMonthName(
            Constants.MonthHelper.Months(rawValue: month) ?? .December
        )
    }
    
    func editMoodEntry(_ entry: MoodEntry) {
        selectedMoodForEdit = entry
        HapticManager.shared.impact(.light)
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        HapticManager.shared.impact(.medium)
        viewModel.deleteMoodEntry(entry)
    }
}

// MARK: - MoodRowView Component
struct MoodRowView: View {
    let mood: MoodEntry
    let formattedDay: String
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onEdit) {
            HStack(alignment: .center, spacing: 16) {
                dateView
                moodContentView
                Spacer()
                chevronIcon
            }
            .frame(height: 80)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.theme.border)
                    .shadow(color: .black.opacity(0.05), radius: isPressed ? 2 : 5, y: isPressed ? 1 : 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }) {
            // Long press action if needed
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            deleteButton
        }
    }
}

// MARK: - MoodRowView Components
private extension MoodRowView {
    var dateView: some View {
        VStack(spacing: 2) {
            Text(dayComponent)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.headingText)
            Text(weekdayComponent)
                .font(.caption)
                .foregroundColor(Color.theme.headingText.opacity(0.7))
        }
        .frame(width: 50)
        .multilineTextAlignment(.center)
    }
    
    var moodContentView: some View {
        HStack(spacing: 12) {
            Text(moodEmoji)
                .font(.title)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(moodNote)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.bodyText)
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                HStack(spacing: 8) {
                    if mood.score > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("\(mood.score)/5")
                                .font(.caption)
                                .foregroundColor(Color.theme.bodyText.opacity(0.7))
                        }
                    }
                    
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(Color.theme.bodyText.opacity(0.5))
    }
    
    var deleteButton: some View {
        Button(role: .destructive, action: onDelete) {
            Label("Delete", systemImage: "trash")
        }
    }
    
    // Computed properties for cleaner code
    var moodEmoji: String {
        mood.moodEmoji ?? "😕"
    }
    
    var moodNote: String {
        mood.note ?? "No note available"
    }
    
    // Date components for better layout
    var dayComponent: String {
        let components = formattedDay.components(separatedBy: "\n")
        return components.first ?? ""
    }
    
    var weekdayComponent: String {
        let components = formattedDay.components(separatedBy: "\n")
        return components.count > 1 ? components[1] : ""
    }
}

// MARK: - Preview
#Preview("Mood List") {
    MoodListView()
}

#Preview("Empty State") {
    MoodListView(month: 1)
}
