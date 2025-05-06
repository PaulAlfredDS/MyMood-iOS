//
//  MoodTrackerApp.swift
//  MoodTracker
//
//  Created by Paul on 4/7/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
      return GIDSignIn.sharedInstance.handle(url)
    }}


@main
struct MoodTrackerApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
        let authManager = AuthManager()
        _authManager = StateObject(wrappedValue: authManager)
    }
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            //            MoodGraphView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext).environmentObject(authManager)
                
            
        }
    }
}
