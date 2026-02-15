//
//  AuthenticatedSessionManager.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/11/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthenticatedSessionManager {
    var authStateHandle: AuthStateDidChangeListenerHandle?
    var authStateDidChange: ((Bool) -> Void)?
    
    func registerAuthStateListener() {
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.authStateDidChange?(user != nil)
        }
        
    }
}
