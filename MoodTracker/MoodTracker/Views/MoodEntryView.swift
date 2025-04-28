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
    private var moodEntry = MoodEntry(context:  CoreDataManager.shared.viewContext)
    
    var body: some View {
        NavigationView {
            VStack(alignment:.center, spacing: 30) {
                
                Text("Select your mood")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                HStack(alignment: .center, spacing: 20, content: {
                    Button {
                        moodEntry.moodEmoji = "😄"
                    } label: {
                        Text("😄")
                            .font(.system(size: 100, weight: .bold, design: .default))
                    }
                    Button {
                        moodEntry.moodEmoji = "😐"
                    } label: {
                        Text("😐")
                            .font(.system(size: 100, weight: .bold, design: .default))
                    }
                    Button {
                        moodEntry.moodEmoji = "😢"
                    } label: {
                        Text("😢")
                            .font(.system(size: 100, weight: .bold, design: .default))
                    }
                    
                })
                Form {
                    TextField(note, text: $note).frame(maxWidth: .infinity, maxHeight: 40).background().cornerRadius(10)
                        .padding()
                    
                    
                    DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date).background().cornerRadius(10)
                }.cornerRadius(20).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)) 
                
                
                Button(action: {
                    moodEntry.id = UUID()
                    moodEntry.note = note
                    moodEntry.date = selectedDate
                    viewModel.addMood(moodEntry)
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
