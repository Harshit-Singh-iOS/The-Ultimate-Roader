//
//  SceneDelegate.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/23/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Firebase
import GoogleSignIn
import FirebaseAuth
import SwiftUI

class SceneDelegate: NSObject, UISceneDelegate {
    let authManager = AuthenticatedSessionManager()
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        FirebaseApp.configure()
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: Constants.kGoogleClientId)
        }
        
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            let controller = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            self.window?.rootViewController = controller
            self.window?.makeKeyAndVisible()
        }
        
        authManager.authStateDidChange = updateAuthenticatedState
        authManager.registerAuthStateListener()
        SwiftMessageBar.setSharedConfig(Theme.barConfig)
    }
}

extension SceneDelegate {
    @MainActor
    func updateAuthenticatedState(_ authenticated: Bool) {
        let controller: UIViewController?
        
        if authenticated {
            controller = UIHostingController(rootView: HomeTabView())
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
