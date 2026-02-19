//
//  HomeTabView.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/15/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI

enum HomeTab {
    case Information, AllDrives, Settings
}

struct HomeTabView: View {
    @State var selected: HomeTab = .Information
    
    var body: some View {
        TabView(selection: $selected) {
            LocalInformationView()
                .tabItem {
                    Image(systemName: "safari")
                    Text("Info")
                }
            
            AllDriveView()
                .tabItem {
                    Image(systemName: "car.top.lane.dashed.badge.steeringwheel")
                    Text("Drive")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .tint(Theme.themeColor)
    }
}

#Preview {
    HomeTabView()
}
