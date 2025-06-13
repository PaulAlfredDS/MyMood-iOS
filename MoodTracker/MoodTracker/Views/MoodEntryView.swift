//
//  MoodEntryView.swift
//  MoodTracker
//
//  Created by Paul on 4/7/25.
//

import SwiftUI
import CoreData

struct MoodEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: MoodEntryViewModel
    
    init(currentDate: Date? = Date(), viewMode: MoodEntryViewModel.ViewMode = .create) {
        _viewModel = StateObject(wrappedValue: MoodEntryViewModel(
            localSource: LocalMoodSource.shared,
            remoteSource: RemoteMoodSource(),
            mode: viewMode,
            selectedDate: currentDate ?? Date()
        ))
        NotificationManager.shared.scheduleNotification()
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 30) {
                // Header with dynamic greeting
                headerView
                
                // Mood selection list
                moodListView
                
                // Note input
                noteView
                
                // Date picker (only in create mode)
                if viewModel.mode == .create {
                    datePickerView
                }
                
                // Save/Update button
                actionButton
            }
            .onAppear {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
            .overlay(alignment: .top) {
                if viewModel.isSuccessfullyAdded {
                    successOverlay
                } else if viewModel.errorMessage != nil {
                    errorOverlay
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.isSuccessfullyAdded)
            .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
            .containerRelativeFrame([.horizontal, .vertical])
            .background(backgroundGradient)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.theme.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await signOutUser()
                        }
                    }) {
                        Text("Sign Out")
                            .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(greeting)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.headingText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if case .edit(let mood) = viewModel.mode {
                Text("Originally logged: \(mood.date?.formatted(date: .abbreviated, time: .shortened) ?? "")")
                    .font(.caption)
                    .foregroundColor(Color.theme.bodyText.opacity(0.7))
            }
        }
    }
    
    private var moodListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select your mood")
                .font(.headline)
                .foregroundColor(Color.theme.headingText)
                .padding(.horizontal, 20)
            
            List(MoodData.moods) { mood in
                HStack {
                    Text(mood.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mood.label)
                            .foregroundColor(Color.theme.bodyText)
                            .fontWeight(viewModel.selectedEmoji == mood.emoji ? .semibold : .regular)
                        
                        Text("Score: \(mood.score)")
                            .font(.caption)
                            .foregroundColor(Color.theme.bodyText.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    if viewModel.selectedEmoji == mood.emoji {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.theme.accent)
                            .font(.title3)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(
                    viewModel.selectedEmoji == mood.emoji
                        ? Color.theme.accent.opacity(0.1)
                        : Color.clear
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.score = Int16(mood.score)
                        viewModel.selectedEmoji = mood.emoji
                        HapticManager.shared.selection()
                    }
                }
            }
            .listStyle(.automatic)
            .frame(maxHeight: 300)
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }
    
    private var noteView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add a note")
                .font(.headline)
                .foregroundColor(Color.theme.headingText)
            
            Text(viewModel.mode.isEdit ? "Update your thoughts" : "What's on your mind?")
                .font(.subheadline)
                .foregroundColor(Color.theme.bodyText.opacity(0.7))
            
            TextEditor(text: $viewModel.note)
                .frame(minHeight: 100, maxHeight: 150)
                .padding(8)
                .background(Color.theme.border.opacity(0.3))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.theme.accent.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(Color.theme.bodyText)
        }
        .padding(.horizontal, 20)
    }
    
    private var datePickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select date")
                .font(.headline)
                .foregroundColor(Color.theme.headingText)
            
            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .accentColor(Color.theme.accent)
        }
        .padding()
        .background(Color.theme.border.opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
    
    private var actionButton: some View {
        Button(action: handleSave) {
            HStack {
                Image(systemName: viewModel.mode.isEdit ? "checkmark.circle" : "plus.circle.fill")
                Text(viewModel.mode.isEdit ? "Update Mood" : "Save Mood")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(
                viewModel.isSelectedEmojiValid
                    ? Color.theme.primary
                    : Color.theme.border
            )
            .foregroundColor(
                viewModel.isSelectedEmojiValid
                    ? Color.theme.primaryButtonText
                    : Color.theme.bodyText.opacity(0.5)
            )
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .scaleEffect(viewModel.isSelectedEmojiValid ? 1.0 : 0.95)
            .animation(.spring(response: 0.3), value: viewModel.isSelectedEmojiValid)
        }
        .disabled(!viewModel.isSelectedEmojiValid)
    }
    
    private var successOverlay: some View {
        Text(viewModel.mode.isEdit ? "Mood updated successfully!" : "Mood saved successfully!")
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
            .shadow(radius: 5)
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.top, 50)
    }
    
    private var errorOverlay: some View {
        Text(viewModel.errorMessage ?? "An error occurred")
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .cornerRadius(10)
            .shadow(radius: 5)
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.top, 50)
            .onTapGesture {
                viewModel.errorMessage = nil
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        viewModel.errorMessage = nil
                    }
                }
            }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color("BG1"), Color("BG2"), Color("BG3"), Color("BG4")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.6)
        .ignoresSafeArea()
    }
    
    // MARK: - Computed Properties
    
    private var navigationTitle: String {
        viewModel.mode.isEdit ? "Edit Mood" : "Add Mood"
    }
    
    private var greeting: String {
        switch viewModel.mode {
        case .create:
            return "How are you feeling today?"
        case .edit(let mood):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d"
            let dateString = dateFormatter.string(from: mood.date ?? Date())
            return "Edit mood for\n\(dateString)"
        }
    }
    
    // MARK: - Methods
    
    private func handleSave() {
        if viewModel.mode.isEdit {
            viewModel.updateMood {
                successfulSave()
            } onFailure: { error in
                print("Error updating mood: \(error)")
            }
        } else {
            viewModel.addMood {
                successfulSave()
            } onFailure: { error in
                print("Error adding mood: \(error)")
            }
        }
    }
    
    private func successfulSave() {
        viewModel.isSuccessfullyAdded = true
        HapticManager.shared.moodSaved()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
    
    private func signOutUser() async {
        do {
            try await authManager.signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

// MARK: - Preview
#Preview("Add Mode") {
    MoodEntryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AuthManager.shared)
}

#Preview("Edit Mode") {
    let context = PersistenceController.preview.container.viewContext
    let sampleMood = MoodEntry(context: context)
    sampleMood.id = UUID()
    sampleMood.moodEmoji = "😊"
    sampleMood.note = "Had a great day today!"
    sampleMood.date = Date()
    sampleMood.score = 4
    
    return MoodEntryView(viewMode: .edit(sampleMood))
        .environment(\.managedObjectContext, context)
        .environmentObject(AuthManager.shared)
}
