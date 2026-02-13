//
//  SignInViewModel.swift
//  Firebase Roader Demo
//
//  Created by Harshit on 2/11/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase

@Observable
class SignInViewModel {
    weak var controller: UIViewController?
    
    init(parent: UIViewController? = nil) {
        self.controller = parent
    }

    func signInWith(email: String, password: String) async -> Result<Any?, Error> {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    func googleSignIn() async -> Result<Any?, Error> {
        do {
            guard let controller else { return .failure(NSError(domain: "No presenting screen", code: -999)) }
            
            let user = try await GIDSignIn.sharedInstance.signIn(withPresenting: controller).user
            
            guard let idToken = user.idToken?.tokenString else {
                return .failure(NSError(domain: "No user", code: -999))
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            saveUser(authResult: result)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    func signUp() {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        signUpViewController?.modalPresentationStyle = .fullScreen
        controller?.present(signUpViewController!, animated: true, completion: nil)
    }
    
    func resetPassword(email: String) async -> Error? {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return nil
        } catch {
            return error
        }
    }
    
    private func saveUser(authResult: AuthDataResult) {
        Task {
            if let uid = Auth.auth().currentUser?.uid {
                let userDict: [String: Any?] = [
                    "FirstName": authResult.user.displayName,
                    "UserId": uid,
                    "EmailID": authResult.user.email
                ]
                
                let ref = Database.database().reference()
                _ = try? await ref.child("Users").child(uid).updateChildValues(userDict as [AnyHashable : Any])
            }
        }
    }
}
