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
                .onChange(of: vm.searchText) { _, _ in vm.applyFilter() }
        }
        .padding(.vertical, 8)
    }
    
    private var listView: some View {
        ForEach(0..<vm.paths.count, id: \.self) { index in
            NavigationLink {
                SelectedPathView(path: vm.paths[index])
                    .ignoresSafeArea()
            } label: {
                AllDriveItemView(path: vm.paths[index])
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

//#Preview {
//    AllDriveView()
//}
