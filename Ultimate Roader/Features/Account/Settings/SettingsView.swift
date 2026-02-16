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
        NavigationStack {
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
            .listStyle(.plain)
            .textFieldStyle(.URStyle)
            .padding()
            .foregroundStyle(.white)
            .font(.headline)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .appBackground()
        }
        
    }
}

#Preview {
    SettingsView()
}
