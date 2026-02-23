//
//  AllDriveView.swift
//  Ultimate Roader
//
//  Created by Assistant on 2/15/26.
//

import SwiftUI

struct AllDriveView: View {
    private enum Route: Hashable {
        case selectedPath(Int)
        case followingUsers(Int)
    }

    @State private var vm = AllDriveViewModel()
    @State private var showingUserPaths = true
    @State private var navPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navPath) {
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
            .onAppear {
                if showingUserPaths {
                    vm.loadUserPaths()
                } else {
                    vm.loadPublicPaths()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .selectedPath(let index):
                    let filtered = showingUserPaths ? vm.filteredMyPaths : vm.filteredPublicPaths
                    if filtered.indices.contains(index) {
                        SelectedPathView(path: filtered[index])
                            .ignoresSafeArea()
                    } else {
                        Text("Drive not available.")
                            .foregroundStyle(.secondary)
                    }
                case .followingUsers(let index):
                    let filtered = showingUserPaths ? vm.filteredMyPaths : vm.filteredPublicPaths
                    if filtered.indices.contains(index) {
                        FollowingUserView(path: filtered[index])
                            .ignoresSafeArea()
                    } else {
                        Text("Drive not available.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        StartDrivingView()
                            .ignoresSafeArea()
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
                .onChange(of: vm.searchText) { _, _ in
                    if showingUserPaths {
                        vm.filterMyPaths()
                    } else {
                        vm.filterPublicPaths()
                    }
                }
        }
        .padding(.vertical, 8)
    }
    
    private var listView: some View {
        let filtered = showingUserPaths ? vm.filteredMyPaths : vm.filteredPublicPaths
        
        return ForEach(0..<filtered.count, id: \.self) { index in
            NavigationLink(value: Route.selectedPath(index)) {
                AllDriveItemView(path: filtered[index],
                                 onSelectFollowers: { navPath.append(Route.followingUsers(index)) })
                .frame(maxWidth: .infinity)
            }
        }
        .onDelete { offsets in
            let section: SectionType = showingUserPaths ? .myDrive : .publicDrive
            vm.deletePath(offset: offsets, section: section)
        }
        .deleteDisabled(!showingUserPaths)
    }
}

//#Preview {
//    AllDriveView()
//}
