//
//  SettingsView.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/15/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI

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
