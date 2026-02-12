//
//  SignInViewController.swift
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

class SignInViewController: UIViewController, UITextFieldDelegate {
    var viewModel = SignInViewModel()
    
    @IBOutlet weak var username_tf: UITextField!
    @IBOutlet weak var password_tf: UITextField!
    @IBOutlet weak var login_btn_view: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        username_tf.text = LoginConstants.em
        password_tf.text = LoginConstants.pass
        
        SwiftMessageBar.setSharedConfig(Theme.barConfig)
        
        let googleButton = GIDSignInButton()
        googleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        googleButton.frame = CGRect(x: 0, y: 0, width: 80, height: 28)
        login_btn_view.addSubview(googleButton)
    }
    
    @IBAction func sign_in_action(_ sender: UIButton) {
        guard let email = username_tf.text, let pass = password_tf.text,
        !email.isEmpty || !pass.isEmpty else {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter Email and Password", type: .error)
            return
        }

        Task { @MainActor [weak self] in
            SVProgressHUD.show()
            
            let result = await self?.viewModel.signInWith(email: email, password: pass)
            
            await SVProgressHUD.dismiss()
            
            switch result {
            case .success, .none:
                SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                self?.username_tf.text = ""
                self?.password_tf.text = ""
            case .failure(let error):
                SwiftMessageBar.showMessageWithTitle("Error", message: error.localizedDescription, type: .error)
            }
        }
    }
    
    @objc private func googleSignInTapped() {
        Task { @MainActor [weak self] in
            let result = await self?.viewModel.googleSignIn(controller: self)
            
            switch result {
            case .success:
                SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
            case .failure(let error):
                SwiftMessageBar.showMessageWithTitle("Error", message: error.localizedDescription, type: .error)
            default:
                break
            }
        }
    }
    
    @IBAction func sign_up_action(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        controller?.modalPresentationStyle = .fullScreen
        present(controller!, animated: true, completion: nil)
    }
    
    @IBAction func reset_password(_ sender: UIButton) {
        guard let email = username_tf.text, !email.isEmpty else {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter Email.", type: .error)
            return
        }
        
        Task { @MainActor in
            let error = await viewModel.resetPassword(email: email)
            
            if error == nil {
                SwiftMessageBar.showMessageWithTitle("Success", message: "Mail Sent", type: .success)
            } else {
                print(error?.localizedDescription ?? "Error")
                SwiftMessageBar.showMessageWithTitle("Error", message: error?.localizedDescription ?? "Unknown error", type: .error)
            }
        }
    }
}
