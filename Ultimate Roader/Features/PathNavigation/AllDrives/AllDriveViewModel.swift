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
    var paths: [Path] = []
    var isLoading = false
    var searchText: String = ""

    private var allPaths: [Path] = []

    func loadUserPaths() {
        isLoading = true
        ManagePathManager.sharedinstance.getUsersPaths { [weak self] all_path in
            guard let self else { return }
            if let paths = all_path as? [Path] {
                self.allPaths = paths
                self.applyFilter()
            } else {
                self.allPaths = []
                self.paths = []
            }
            self.isLoading = false
        }
    }

    func loadPublicPaths() {
        isLoading = true
        ManagePathManager.sharedinstance.getAllPublicPaths { [weak self] all_path in
            guard let self else { return }
            if let paths = all_path as? [Path] {
                self.allPaths = paths
                self.applyFilter()
            } else {
                self.allPaths = []
                self.paths = []
            }
            self.isLoading = false
        }
    }

    func applyFilter() {
        guard !searchText.isEmpty else { paths = allPaths; return }
        let query = searchText.lowercased()
        paths = allPaths.filter { ($0.pathName ?? "").lowercased().contains(query) }
    }
}
