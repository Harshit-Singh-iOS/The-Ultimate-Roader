//
//  SignInView.swift
//  Firebase Roader Demo
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI
import GoogleSignIn

struct SignInView: View {
    var viewModel: SignInViewModel
    
    @State private var email: String = LoginConstants.em
    @State private var password: String = LoginConstants.pass
    @State private var isLoading: Bool = false
    
    var body: some View {
        Image("Intro_screen")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blur(radius: 8)
            .ignoresSafeArea()
            .overlay {
                signInForm
                    .frame(maxWidth: 300)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                }
            }
    }
    
    private var signInForm: some View {
        VStack(alignment: .center, spacing: 24) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
            
            TextField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            signInButtons
            
            otherButtons
        }
    }
    
    private var signInButtons: some View {
        Group {
            Button("Sign In") {
                guard !email.isEmpty || !password.isEmpty else {
                    SwiftMessageBar.showMessageWithTitle("Error", message: "Enter Email and Password", type: .error)
                    return
                }
                
                Task { @MainActor in
                    isLoading = true
                    let result = await viewModel.signInWith(email: email, password: password)
                    isLoading = false
                    
                    switch result {
                    case .success:
                        SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                    case .failure(let error):
                        SwiftMessageBar.showMessageWithTitle("Error", message: error.localizedDescription, type: .error)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                Task { @MainActor in
                    isLoading = true
                    let result = await self.viewModel.googleSignIn()
                    isLoading = false
                    
                    switch result {
                    case .success:
                        SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                    case .failure(let error):
                        SwiftMessageBar.showMessageWithTitle("Error", message: error.localizedDescription, type: .error)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "g.circle")
                    Text("Sign in with Google")
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .tint(Theme.themeColor)
    }
    
    private var otherButtons: some View {
        HStack {
            Button("Sign up") {
                viewModel.signUp()
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Theme.themeColor)
            
            Button("Reset password") {
                guard !email.isEmpty else {
                    SwiftMessageBar.showMessageWithTitle("Error", message: "Enter Email.", type: .error)
                    return
                }
                
                Task { @MainActor in
                    isLoading = true
                    let error = await viewModel.resetPassword(email: email)
                    isLoading = false
                    if error == nil {
                        SwiftMessageBar.showMessageWithTitle("Success", message: "Mail Sent", type: .success)
                    } else {
                        SwiftMessageBar.showMessageWithTitle("Error", message: error?.localizedDescription ?? "Unknown error", type: .error)
                    }
                }
                
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Theme.themeColor)
        }
    }
}

#Preview {
    SignInView(viewModel: .init(parent: nil))
}
