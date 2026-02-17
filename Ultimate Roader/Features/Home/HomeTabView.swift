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
            
            AllDrivesVC()
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "car.top.lane.dashed.badge.steeringwheel")
                    Text("Drive")
                }
            
            AllDriveView()
                .tabItem {
                    Image(systemName: "car.top.lane.dashed.badge.steeringwheel")
                    Text("NEW Drive")
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

struct AllDrivesVC: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AllPathViewController") as! AllPathViewController
        let nav = UINavigationController(rootViewController: controller)
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}

#Preview {
    HomeTabView()
}
