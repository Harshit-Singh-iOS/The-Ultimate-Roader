//
//  AppDelegate.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 10/17/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let authManager = AuthenticatedSessionManager()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: Constants.kGoogleClientId)
        }
        authManager.authStateDidChange = updateAuthenticatedState
        authManager.registerAuthStateListener()
        SwiftMessageBar.setSharedConfig(Theme.barConfig)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

extension AppDelegate {
    @MainActor
    func updateAuthenticatedState(_ authenticated: Bool) {
        let controller: UIViewController?
        
        if authenticated {
            controller = UIHostingController(rootView: HomeTabView())
//            let storyboard = UIStoryboard(name: "Home", bundle: nil)
//            controller = storyboard.instantiateViewController(withIdentifier: "HomeNavigationController")
        } else {
            let view = SignInView(viewModel: .init())
            let hostVC = UIHostingController(rootView: view)
            (hostVC.rootView as SignInView).viewModel.controller = hostVC
            controller = hostVC
        }
        
        if window == nil { window = UIWindow(frame: UIScreen.main.bounds) }
        guard let window else { return }
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}
