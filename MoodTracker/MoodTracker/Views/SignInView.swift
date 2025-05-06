//
//  SignInView.swift
//  MoodTracker
//
//  Created by Paul on 5/6/25.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignInSwift


struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        GoogleSignInButton {
            Task {
                await signInWithGoogle()
            }
        }.frame(width: 280, height: 45, alignment: .center)
    
    }
    
    func signInWithGoogle() async {
        do {
            guard let user = try await GoogleSignInManager.shared.signInWithGoogle() else { return }
            
            let result = try await authManager.googleAuth(user)
            if let result = result {
                print("GoogleSignInSuccess: \(result.user.uid)")
            }
        }
        catch {
            print("GoogleSignInError: \(error.localizedDescription)")
        }
    }
    
}
