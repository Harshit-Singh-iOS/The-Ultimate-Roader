//
//  ViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/17/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import GoogleSignIn

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var username_tf: UITextField!
    @IBOutlet weak var password_tf: UITextField!
    @IBOutlet weak var verification_tf: UITextField!
    
    @IBOutlet weak var login_btn_view: UIView!
    var ref: DatabaseReference?
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        SwiftMessageBar.setSharedConfig(barConfig)        
        
        let googleButton = GIDSignInButton()
        googleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        googleButton.frame = CGRect(x: 0, y: 0, width: 80, height: 28)
        login_btn_view.addSubview(googleButton)
        
        username_tf.text = LoginConstants.em
        password_tf.text = LoginConstants.pass
    }
    
    @IBAction func phonesigninAction(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Send Code" {
            if let phone_num = username_tf.text {
                PhoneAuthProvider.provider().verifyPhoneNumber(phone_num, uiDelegate: nil) { (verificationID, error) in
                    Auth.auth().languageCode = "en"
                    if let error = error {
                        SwiftMessageBar.showMessageWithTitle("Error", message: error.localizedDescription, type: .error)
                        return
                    } else {
                        
                        sender.setTitle("Verify", for: .normal)
                        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    }
                }
            } else {
                SwiftMessageBar.showMessageWithTitle("Enter phone number", message: "", type: .error)
            }
            
        } else if sender.titleLabel?.text == "Verify" {
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID!,
                verificationCode: verification_tf.text!)
            
            Auth.auth().signIn(with: credential) { (_, error) in
                if let error = error {
                    return
                }
                SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
                self.present(controller!, animated: true, completion: nil)
            }
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        signInwithUserandPass()
        return true
    }
    @IBAction func sign_in_action(_ sender: UIButton) {
        signInwithUserandPass()
    }
    
    func signInwithUserandPass() {
        guard let user = username_tf.text, let pass = password_tf.text else {
            return
        }

        if user.isEmpty || pass.isEmpty {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter Username and Password", type: .error)
        } else {
            
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: user, password: pass) { (_, error) in
                if let err = error {
                    print(err.localizedDescription)
                    SwiftMessageBar.showMessageWithTitle("Error", message: "Username or Password wrong", type: .error)
                } else {
                    SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
                    controller?.modalPresentationStyle = .fullScreen
                    self.present(controller!, animated: true, completion: nil)
                }
                self.username_tf.text = ""
                self.password_tf.text = ""
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc private func googleSignInTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                if let uid = Auth.auth().currentUser?.uid {
                    let userDict: [String: Any?] = [
                        "FirstName": authResult?.user.displayName,
                        "UserId": uid,
                        "EmailID": authResult?.user.email
                    ]

                    self.ref?.child("Users").child(uid).updateChildValues(userDict, withCompletionBlock: { (error, _) in
                        if error == nil {
                            SwiftMessageBar.showMessageWithTitle("Congrats!!", message: "Sign Up successful.", type: .success)
                        } else {
                            print(error?.localizedDescription ?? "Error")
                            SwiftMessageBar.showMessageWithTitle("Error", message: "Something went wrong.", type: .error)
                        }
                    })
                }

                SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
                self.present(controller!, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func sign_up_action(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        present(controller!, animated: true, completion: nil)
    }
    
    @IBAction func reset_password(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: "harshitsingh0401@gmail.com") { (error) in
            
            if error == nil {
                SwiftMessageBar.showMessageWithTitle("Success", message: "Mail Sent", type: .success)
            }
            else {
                print(error?.localizedDescription ?? "Error")
                SwiftMessageBar.showMessageWithTitle("Error", message: error?.localizedDescription ?? "Unknown error", type: .error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
}
