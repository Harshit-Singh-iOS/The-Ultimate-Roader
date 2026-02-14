//
//  SignUpViewModel.swift
//  Firebase Roader Demo
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import UIKit
import _PhotosUI_SwiftUI

class SignUpViewModel {
    var databaseRef: DatabaseReference?
    var storageRef = Storage.storage().reference()
    var fName: String = ""
    var lName: String = ""
    var email: String = ""
    var city: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var pickerItem: PhotosPickerItem?
    var pickedImageData: Data?
    var pickedImageUrl: URL?
    
    init() {
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    private func prepTestUI() {
        fName = "Harry"
        lName = "S"
        email = LoginConstants.em
        password = LoginConstants.pass
        confirmPassword = LoginConstants.pass
        city = "IND"
    }
    
    func createUser() async -> Result<Bool, Error> {
        do {
            let user = try await Auth.auth().createUser(withEmail: email, password: password).user
            var userDict = ["FirstName": fName,
                            "LastName": lName,
                            "UserId": user.uid,
                            "EmailID": email,
                            "City": city] as [String : Any]
            
            if pickedImageData != nil {
                let url = try await self.uploadingImage()
                userDict["userImageUrl"] = url.absoluteString
            }
            
            _ = try await self.databaseRef?.child("Users").child(user.uid).updateChildValues(userDict)
            
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    private func uploadingImage() async throws -> URL {
        guard let pickedImageData,
              let id = Auth.auth().currentUser
        else { throw NSError(domain: "No image to upload", code: 999) }
        
        do {
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let imagename = "UserImages/\(String(describing:id.uid)).jpeg"
            storageRef = storageRef.child(imagename)
            _ = try await storageRef.putDataAsync(pickedImageData, metadata: metaData)
            
            return try await withCheckedThrowingContinuation { continuation in
                storageRef.downloadURL { url, error in
                    if let url {
                        continuation.resume(returning: url)
                    } else if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: NSError(domain: "No image url", code: 999))
                    }
                }
            }
        } catch {
            throw error
        }
    }
}
