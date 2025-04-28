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
    private var moodEntry = MoodEntry(context:  CoreDataManager.shared.viewContext)
    
    var body: some View {
        NavigationView {
            VStack(alignment:.center, spacing: 30) {

                Text("Select your mood")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                List(MoodData.moods, id: \.emoji, selection: $selectedMood) { mood in
                    Text(mood.emoji+" "+mood.label)
                }
                .listStyle(.automatic).cornerRadius(10).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                Form {
                    TextField(note, text: $note).frame(maxWidth: .infinity, maxHeight: 40).background().cornerRadius(10)
                        .padding()
                    
                    
                    DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date).background().cornerRadius(10)
                }.cornerRadius(20).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)) 
                
                
                Button(action: {
                    moodEntry.id = UUID()
                    moodEntry.moodEmoji = selectedMood ?? ""
                    moodEntry.note = note
                    moodEntry.date = selectedDate
                    if (selectedMood != nil || selectedMood != "") {
                        viewModel.addMood(moodEntry)
                    } else {
                        print("Please select a mood")
                    }
                    
                }) {
                    Text("Save").frame(maxWidth: .infinity, maxHeight: 50).background().cornerRadius(20).padding()
                }
            }.containerRelativeFrame([.horizontal, .vertical])
                .background(Gradient(colors: [.yellow, .orange, .red]).opacity(0.6))
        }
    }

}


#Preview {
    MoodEntryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
