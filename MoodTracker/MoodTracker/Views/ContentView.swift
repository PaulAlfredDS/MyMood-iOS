//
//  ContentView.swift
//  MoodTracker
//
//  Created by Paul on 5/6/25.
//

import Foundation
import SwiftUI

struct ContentView: View{
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack{
            if authManager.authState == .signedIn {
                MoodEntryView()
            } else {
                SignInView()
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(AuthManager())
}
