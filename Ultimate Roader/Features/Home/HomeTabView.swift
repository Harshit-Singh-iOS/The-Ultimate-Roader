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
            
            AllDrives()
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

struct AllDrives: UIViewRepresentable {
    let controller: AllPathViewController
    
    init() {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AllPathViewController") as! AllPathViewController
        self.controller = controller
    }
    
    func makeUIView(context: Context) -> UIView {
        controller.view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        controller.view = uiView
    }
}

#Preview {
    HomeTabView()
}
