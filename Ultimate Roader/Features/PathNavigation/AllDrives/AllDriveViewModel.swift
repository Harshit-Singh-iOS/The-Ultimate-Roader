//
//  AllDriveViewModel.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/16/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation

@Observable
final class AllDriveViewModel {
    var filteredMyPaths: [Path] = []
    var filteredPublicPaths: [Path] = []
    var isLoading = false
    var searchText: String = ""

    private var myPaths: [Path] = []
    private var publicPaths: [Path] = []

    func loadUserPaths() {
        isLoading = true
        ManagePathManager.sharedinstance.getUsersPaths { [weak self] all_path in
            self?.isLoading = false
            guard let self else { return }
            if let paths = all_path as? [Path] {
                self.myPaths = paths.sorted(by: { $0.createdDate ?? .distantPast > $1.createdDate ?? .distantPast })
                self.filterMyPaths()
            } else {
                self.myPaths = []
                self.filteredMyPaths = []
            }
        }
    }

    func loadPublicPaths() {
        isLoading = true
        ManagePathManager.sharedinstance.getAllPublicPaths { [weak self] all_path in
            self?.isLoading = false
            guard let self else { return }
            if let paths = all_path as? [Path] {
                self.publicPaths = paths.sorted(by: { $0.createdDate ?? .distantPast > $1.createdDate ?? .distantPast })
                self.filterPublicPaths()
            } else {
                self.publicPaths = []
                self.filteredPublicPaths = []
            }
        }
    }

    func filterMyPaths() {
        guard !searchText.isEmpty else { filteredMyPaths = myPaths; return }
        let query = searchText.lowercased()
        filteredMyPaths = myPaths.filter { ($0.pathName ?? "").lowercased().contains(query) }
    }

    func filterPublicPaths() {
        guard !searchText.isEmpty else { filteredPublicPaths = publicPaths; return }
        let query = searchText.lowercased()
        filteredPublicPaths = publicPaths.filter { ($0.pathName ?? "").lowercased().contains(query) }
    }
    
    func deletePath(offset: IndexSet, section: SectionType) {
        Task {
            switch section {
            case .myDrive:
                for index in offset {
                    let path = myPaths[index]
                    await ManagePathManager.sharedinstance.deletePath(path: path)
                }
                loadUserPaths()
            case .publicDrive:
                for index in offset {
                    let path = publicPaths[index]
                    await ManagePathManager.sharedinstance.deletePath(path: path)
                }
                loadPublicPaths()
            }
        }
    }
}
enum SectionType {
    case myDrive
    case publicDrive
}

