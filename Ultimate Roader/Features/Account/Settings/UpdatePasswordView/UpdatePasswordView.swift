//
//  UpdatePasswordView.swift
//  Ultimate Roader
//
//  Created by Assistant on 2/15/26.
//

import SwiftUI
import FirebaseAuth

struct UpdatePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            SecureField("Old password", text: $oldPassword)
            SecureField("New password", text: $newPassword)
            SecureField("Confirm password", text: $confirmPassword)

            Button("Update") { changePassword() }
                .buttonStyle(.URPrimary)
                .padding(.top, 12)
        }
        .textFieldStyle(.URStyle)
        .frame(width: 300)
        .navigationTitle("Change password")
        .navigationBarTitleDisplayMode(.inline)
        .appBackground()
        .overlay {
            if isLoading { ProgressView().tint(Theme.themeColor) }
        }
    }

    private func changePassword() {
        guard let user = Auth.auth().currentUser else { return }

        if newPassword.isEmpty || confirmPassword.isEmpty {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Password is empty.", type: .error)
            return
        }
        guard newPassword == confirmPassword else {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Passwords do not match.", type: .error)
            return
        }
        guard let email = user.email, !oldPassword.isEmpty else {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter your current password.", type: .error)
            return
        }

        Task { @MainActor in
            isLoading = true
            let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
            do {
                _ = try await user.reauthenticate(with: credential)
                try await user.updatePassword(to: newPassword)
                SwiftMessageBar.showMessageWithTitle("Success", message: "Password Change Successful.", type: .success)
                dismiss()
            } catch {
                SwiftMessageBar.showMessageWithTitle("Error", message: error.localizedDescription, type: .error)
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack { UpdatePasswordView() }
}
