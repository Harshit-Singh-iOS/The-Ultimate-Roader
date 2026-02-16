//
//  SettingsView.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/15/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink("Profile") {
                UserProfileView()
            }
            .listRowBackground(Color.clear)
            
            NavigationLink("Change Password") {
                UpdatePasswordView()
            }
            .listRowBackground(Color.clear)
            
            Button("Sign out", role: .destructive) {
                do {
                    try Auth.auth().signOut()
                    SwiftMessageBar.showMessageWithTitle("Sign Out", message: "Sign out successful.", type: .success)
                } catch {
                    SwiftMessageBar.showMessageWithTitle("Problem!!", message: "Something went wrong.", type: .error)
                }
            }
            .listRowBackground(Color.clear)
        }
        .textFieldStyle(.URStyle)
        .padding()
        .listStyle(.plain)
        .foregroundStyle(.white)
        .font(.headline)
        .appBackground()
        
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
