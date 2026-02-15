//
//  SignUpView.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: SignUpViewModel = .init()
    @State private var processingImage: Bool = false
    @State private var signUpProgress: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileImagePicker
                        .padding(.top, 32)
                        .padding(.bottom, 24)
                    
                    TextField("First name", text: $vm.fName)
                    TextField("Last name", text: $vm.lName)
                    TextField("Email", text: $vm.email)
                    TextField("city", text: $vm.city)
                    SecureField("Password", text: $vm.password)
                    SecureField("Confirm password", text: $vm.confirmPassword)
                }
                .textFieldStyle(.URStyle)
                .frame(width: 300)
            }
            .safeAreaInset(edge: .bottom) {
                Button("Sign up") {
                    createUser()
                }
                .buttonStyle(.URPrimary)
                .padding(.top, 32)
            }
            .appBackground()
            .navigationTitle("Sign up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Theme.themeColor)
                    }
                }
            }
            .overlay {
                if signUpProgress {
                    ProgressView()
                        .tint(Theme.themeColor)
                }
            }
        }
    }
    
    private var profileImagePicker: some View {
        PhotosPicker(selection: $vm.pickerItem, matching: .images) {
            if let pickedImageData = vm.pickedImageData,
               let uiImage = UIImage(data: pickedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .clipShape(.circle)
                    .overlay {
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .tint(.gray)
                    .clipShape(.circle)
            }
        }
        .frame(width: 100, height: 100)
        .overlay {
            if processingImage {
                ProgressView()
                    .tint(Theme.themeColor)
            }
        }
        .onChange(of: vm.pickerItem) { _, newValue in
            Task { @MainActor in
                processingImage = true
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    vm.pickedImageData = data
                }
                processingImage = false
            }
        }
    }
    
    private func createUser() {
        if vm.fName.isEmpty {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter first name", type: .error)
        } else if vm.lName.isEmpty {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter last name", type: .error)
        } else if vm.email.isEmpty {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter email name", type: .error)
        } else if vm.city.isEmpty {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter city", type: .error)
        } else if vm.password.isEmpty {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter password", type: .error)
        } else if vm.confirmPassword.isEmpty {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter confirm password", type: .error)
        } else if vm.password != vm.confirmPassword {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Password do not match!", type: .error)
        } else {
            Task { @MainActor in
                signUpProgress = true
                switch await vm.createUser() {
                case .success:
                    SwiftMessageBar.showMessageWithTitle("Congrats!!", message: "Sign Up successful.", type: .success)
                case .failure(let error):
                    let errorMessage = "Something went wrong: \((error as NSError).domain)"
                    SwiftMessageBar.showMessageWithTitle("Error.", message: errorMessage, type: .error)
                }
                signUpProgress = false
            }
        }
    }
}

#Preview {
    SignUpView()
}
