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
    @EnvironmentObject private var authManager: AuthManager
    
    @StateObject private var viewModel = MoodEntryViewModel(
        localSource: LocalMoodSource.shared,
        remoteSource: RemoteMoodSource()
    )
    
    init() {
        NotificationManager.shared.scheduleNotification()
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment:.center, spacing: 30) {
                Text("How are you today?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                moodListView
                
                noteView
                
                datePickerView
                
                Button(action: {
                    viewModel.addMood()
                    startOneTimeTimer()
                }) {
                    Text("Save").frame(maxWidth: .infinity, maxHeight: 50).background().cornerRadius(20).padding()
                }.disabled(!viewModel.isSelectedEmojiValid)
                
                if viewModel.hasMoodData(on: Calendar.current.component(.month, from: Date())) {
                    NavigationLink(destination: MoodGraphView()) {
                        Text("View Mood Graph").frame(maxWidth: .infinity, maxHeight: 50).background().cornerRadius(20).padding()
                    }
                }
            }
            .onAppear() {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
            .overlay(alignment:.top) {
                if self.viewModel.isSuccessfullyAdded {
                    Text("Mood saved successfully!")
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .transition(.slide)
                }
            }.animation(.easeInOut(duration: 0.3), value: self.viewModel.isSuccessfullyAdded)
                .containerRelativeFrame([.horizontal, .vertical])
                .background(Gradient(colors: [Color("BG1"), Color("BG2"),Color("BG3"), Color("BG4")]).opacity(0.6))
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing, content: {
                        Button(action:  {
                            Task {
                                await signOutUser()
                            }
                        }) {
                            Text("Sign Out")
                        }
                    })
                }
        }
    }
    
    var moodListView: some View {
        List(MoodData.moods) { mood in
            HStack {
                Text(mood.emoji + " " + mood.label)
                Spacer()
                if viewModel.selectedEmoji == mood.emoji {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle()) // Makes the entire row tappable
            .onTapGesture {
                viewModel.score = Int16(mood.score)
                viewModel.selectedEmoji = mood.emoji
            }
        }
        .listStyle(.automatic)
        .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    var noteView: some View {
        Form {
            Text("Do you want to add a note?")
                .font(.subheadline)
                .fontWeight(.bold)
            
            
            TextField("Add a note. . . ", text: $viewModel.note).frame(maxWidth: .infinity, maxHeight: 40).background().cornerRadius(10)
                .padding()
            
        }.cornerRadius(20).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    var datePickerView: some View {
        DatePicker("Date", selection: $viewModel.selectedDate, in: ...Date(), displayedComponents: .date).background().cornerRadius(10).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    func signOutUser() async {
        do {
            try await authManager.signOut()
        } catch {
            print("Error signing out: \(error)")
        }
        
    }
    
    func startOneTimeTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel.isSuccessfullyAdded = false
        }
    }
}


#Preview {
    MoodEntryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
