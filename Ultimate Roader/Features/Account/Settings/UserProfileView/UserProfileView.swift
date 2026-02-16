//
//  UserProfileView.swift
//  Ultimate Roader
//
//  Created by Assistant on 2/15/26.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm = UserProfileViewModel()
    @State private var processingImage = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileImagePicker
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                
                TextField("First name", text: $vm.fName)
                TextField("Last name", text: $vm.lName)
                TextField("Email", text: $vm.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                TextField("City", text: $vm.city)
                
                Button("Save") { save() }
                    .buttonStyle(.URPrimary)
            }
            .textFieldStyle(.URStyle)
            .frame(width: 300)
        }
        .appBackground()
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if vm.isLoading { ProgressView().tint(Theme.themeColor) }
        }
        .task {
            await vm.loadUser()
        }
    }
    
    private var profileImagePicker: some View {
        PhotosPicker(selection: $vm.pickerItem, matching: .images) {
            if let data = vm.pickedImageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(Circle())
                    .overlay { Circle().stroke(.white, lineWidth: 2) }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .tint(.gray)
                    .clipShape(Circle())
            }
        }
        .frame(width: 100, height: 100)
        .overlay {
            if processingImage { ProgressView().tint(Theme.themeColor) }
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
    
    private func save() {
        Task { @MainActor in
            let result = await vm.save()
            switch result {
            case .success:
                SwiftMessageBar.showMessageWithTitle("Success", message: "Profile update successful.", type: .success)
            case .failure(let error):
                SwiftMessageBar.showMessageWithTitle("Cannot update", message: error.localizedDescription, type: .error)
            }
        }
    }
}

#Preview {
    NavigationStack { UserProfileView() }
}
