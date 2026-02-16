//
//  HomeTabViewController.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 10/23/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import SwiftUI

class HomeTabViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HOME"
        SwiftMessageBar.setSharedConfig(Theme.barConfig)
        // Do any additional setup after loading the view.
    }

    @IBAction func setting_action(_ sender: UIButton) {
        let controller = UIHostingController(rootView: SettingsView())
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func information_btn_action(_ sender: UIButton) {
        let controller = UIHostingController(rootView: LocalInformationView())
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func allDrivesAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "AllPathViewController") as? AllPathViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func startDriveAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "PathNavigation", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "StartDrivingViewController") as? StartDrivingViewController
        {
            SwiftMessageBar.showMessageWithTitle("See Map", message: "Start Driving.", type: .info)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func Signout_action(_ sender: UIButton) {
        SVProgressHUD.show()
        do {
            try Auth.auth().signOut()
            SwiftMessageBar.showMessageWithTitle("Sign Out", message: "Sign out successful.", type: .success)
        }
        catch {
            SwiftMessageBar.showMessageWithTitle("Problem!!", message: "Something went wrong.", type: .error)
        }
        SVProgressHUD.dismiss()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
}
