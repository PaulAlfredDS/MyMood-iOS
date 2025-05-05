//
//  ContentView.swift
//  MoodTracker
//
//  Created by Paul on 4/7/25.
//

import SwiftUI
import CoreData

struct MoodEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel = MoodViewModel(
        localSource: LocalMoodSource.shared,
        remoteSource: RemoteMoodSource()
    )
    @State private var note = ""
    @State private var selectedDate = Date()
    @State private var selectedMood: String?
    @State private var score = 0
    @State private var showSuccess = false
    private var moodEntry = MoodEntry(context:  CoreDataManager.shared.viewContext)
    
    var body: some View {
        NavigationView {
            VStack(alignment:.center, spacing: 30) {
                Text("How are you today?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                List(MoodData.moods) { mood in
                    HStack {
                        Text(mood.emoji + " " + mood.label)
                        Spacer()
                        if selectedMood == mood.emoji {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle()) // Makes the entire row tappable
                    .onTapGesture {
                        score = mood.score
                        selectedMood = mood.emoji
                    }
                }
                .listStyle(.automatic)
                .cornerRadius(10)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                
                Form {
                    
                    Text("Do you want to add a note?")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    TextField(note, text: $note).frame(maxWidth: .infinity, maxHeight: 40).background().cornerRadius(10)
                        .padding()
                    
                }.cornerRadius(20).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date).background().cornerRadius(10).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                
                Button(action: {
                    moodEntry.id = UUID()
                    moodEntry.moodEmoji = selectedMood ?? ""
                    moodEntry.note = note
                    moodEntry.date = selectedDate
                    moodEntry.score = Int16(score)
                    if selectedMood != nil && selectedMood != "" {
                        viewModel.addMood(moodEntry)
                        showSuccess = true
                        startOneTimeTimer()
                    } else {
                        print("Please select a mood")
                    }
                    
                }) {
                    Text("Save").frame(maxWidth: .infinity, maxHeight: 50).background().cornerRadius(20).padding()
                }
                
                if viewModel.hasMoodData(on: Calendar.current.component(.month, from: Date())) {
                    
                    NavigationLink(destination: MoodGraphView()) {
                        Text("View Mood Graph").frame(maxWidth: .infinity, maxHeight: 50).background().cornerRadius(20).padding()
                    }
                }
            }
            .overlay(alignment:.top) {
                if showSuccess {
                    Text("Mood saved successfully!")
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .transition(.slide)
                }
            }.animation(.easeInOut(duration: 0.3), value: showSuccess)
                .containerRelativeFrame([.horizontal, .vertical])
                .background(Gradient(colors: [.blue,.orange, .purple]).opacity(0.6))
        }
        
        
    }
    
    func startOneTimeTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showSuccess = false
        }
    }
}


#Preview {
    MoodEntryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
