//
//  UserProfileViewModel.swift
//  Ultimate Roader
//
//  Created by Assistant on 2/15/26.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftUI
import _PhotosUI_SwiftUI

@Observable
class UserProfileViewModel {
    var fName: String = ""
    var lName: String = ""
    var email: String = ""
    var city: String = ""
    var pickedImageData: Data?
    var pickerItem: PhotosPickerItem?
    var isLoading: Bool = false

    var databaseRef: DatabaseReference?
    var storageRef = Storage.storage().reference()

    init() {
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }

    func loadUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let snapshot = try await databaseRef?.child("Users").child(uid).getData()
            if let dict = snapshot?.value as? [String: Any] {
                self.fName = dict["FirstName"] as? String ?? ""
                self.lName = dict["LastName"] as? String ?? ""
                self.email = dict["EmailID"] as? String ?? ""
                self.city = dict["City"] as? String ?? ""
                if let urlString = dict["userImageUrl"] as? String, let url = URL(string: urlString) {
                    // fetch image data lightly (best-effort)
                    if let data = try? Data(contentsOf: url) { self.pickedImageData = data }
                }
            }
        } catch {
            // silent for now; surface with SwiftMessageBar from the view if desired
        }
    }

    func save() async -> Result<Bool, Error> {
        guard let uid = Auth.auth().currentUser?.uid else {
            return .failure(NSError(domain: "No user", code: -999))
        }
        isLoading = true
        defer { isLoading = false }
        do {
            var update: [String: Any] = [
                "FirstName": fName,
                "LastName": lName,
                "EmailID": email,
                "City": city
            ]
            if let data = pickedImageData {
                if let url = try await uploadImage(data: data, uid: uid) {
                    update["userImageUrl"] = url.absoluteString
                }
            }
            _ = try await databaseRef?.child("Users").child(uid).updateChildValues(update)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }

    private func uploadImage(data: Data, uid: String) async throws -> URL? {
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let path = "UserImages/\(uid).jpeg"
        let ref = storageRef.child(path)
        _ = try await ref.putDataAsync(data, metadata: metaData)
        return try await withCheckedThrowingContinuation { continuation in
            ref.downloadURL { url, error in
                if let url { continuation.resume(returning: url) }
                else if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: nil) }
            }
        }
    }
}
