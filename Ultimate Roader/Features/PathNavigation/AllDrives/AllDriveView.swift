//
//  AllDriveView.swift
//  Ultimate Roader
//
//  Created by Assistant on 2/15/26.
//

import SwiftUI

struct AllDriveView: View {
    @State private var vm = AllDriveViewModel()
    @State private var showingUserPaths = true
    
    var body: some View {
        NavigationStack {
            List {
                header
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                
                listView
                    .listRowBackground(Color.clear)
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                
                Spacer(minLength: 60)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Drive List")
            .navigationBarTitleDisplayMode(.inline)
            .appBackground()
            .onAppear { vm.loadUserPaths() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "steeringwheel")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .tint(Theme.themeColor)
                    }
                }
            }
        }
        .overlay { if vm.isLoading { ProgressView().tint(Theme.themeColor) } }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Picker("Scope", selection: $showingUserPaths) {
                Text("Mine").tag(true)
                Text("Public").tag(false)
            }
            .pickerStyle(.segmented)
            .tint(.white)
            .onChange(of: showingUserPaths) { _, newValue in
                if newValue { vm.loadUserPaths() } else { vm.loadPublicPaths() }
            }
            
            TextField("Search", text: $vm.searchText)
                .textFieldStyle(.URStyle)
                .onChange(of: vm.searchText) { _, _ in vm.applyFilter() }
        }
        .padding(.vertical, 8)
    }
    
    private var listView: some View {
        ForEach(0..<vm.paths.count, id: \.self) { index in
            Button {
                openSelected(path: vm.paths[index])
            } label: {
                AllDriveItemView(path: vm.paths[index], didTapFollowingUser: navigateUserToFollowing)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func openSelected(path: Path) {
        guard let fileName = path.pathID else { return }
        let storyboard = UIStoryboard(name: "PathNavigation", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "SelectedPathViewController") as? SelectedPathViewController {
            controller.path = path
            controller.file_name = fileName
            controller.name = path.pathName ?? ""
            UIApplication.shared.topMostNavigationController()?.pushViewController(controller, animated: true)
        }
    }
    
    func navigateUserToFollowing(path: Path) {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "FollowingUserViewController") as? FollowingUserViewController {
            controller.path = path
            UIApplication.shared.topMostNavigationController()?.pushViewController(controller, animated: true)
        }
    }
    
    func navigateUserToStartDriving() {
        let storyboard = UIStoryboard(name: "PathNavigation", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "StartDrivingViewController") as? StartDrivingViewController {
            UIApplication.shared.topMostNavigationController()?.pushViewController(controller, animated: true)
        }
    }
}

//#Preview {
//    AllDriveView()
//}

private extension UIApplication {
    func topMostNavigationController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UINavigationController? {
            if let nav = base as? UINavigationController { return nav }
            if let tab = base as? UITabBarController { return topMostNavigationController(base: tab.selectedViewController) }
            if let presented = base?.presentedViewController { return topMostNavigationController(base: presented) }
            if let nav = base?.navigationController { return nav }
            return nil
        }
}
