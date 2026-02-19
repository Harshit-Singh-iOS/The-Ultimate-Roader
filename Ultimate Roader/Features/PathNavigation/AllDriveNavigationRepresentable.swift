//
//  AllDriveNavigationRepresentable.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/18/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI

struct SelectedPathView: UIViewControllerRepresentable {
    var path: Path
    
    func makeUIViewController(context: Context) -> SelectedPathViewController {
        let storyboard = UIStoryboard(name: "PathNavigation", bundle: nil)
        
        guard let fileName = path.pathID,
              let controller = storyboard.instantiateViewController(withIdentifier: "SelectedPathViewController") as? SelectedPathViewController
        else { return SelectedPathViewController() }
        
        controller.path = path
        controller.file_name = fileName
        controller.navigationController?.title = path.pathName ?? ""
        controller.title = path.pathName ?? ""
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SelectedPathViewController, context: Context) {
        
    }
}

struct FollowingUserView: UIViewControllerRepresentable {
    var path: Path
    
    func makeUIViewController(context: Context) -> FollowingUserViewController {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "FollowingUserViewController") as? FollowingUserViewController {
            controller.path = path
            return controller
        }
        return FollowingUserViewController()
    }
    
    func updateUIViewController(_ uiViewController: FollowingUserViewController, context: Context) {
    }
    
}

struct StartDrivingView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> StartDrivingViewController {
        let storyboard = UIStoryboard(name: "PathNavigation", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "StartDrivingViewController") as? StartDrivingViewController {
            return controller
        }
        return StartDrivingViewController()
    }
    
    func updateUIViewController(_ uiViewController: StartDrivingViewController, context: Context) {
    }
}
