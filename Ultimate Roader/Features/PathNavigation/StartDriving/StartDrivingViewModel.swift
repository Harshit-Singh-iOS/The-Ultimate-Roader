//
//  StartDrivingViewModel.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import Firebase
import FirebaseAuth

class StartDrivingViewModel {
    private var databaseRef: DatabaseReference?
    private var storageRef = Storage.storage().reference()
    
    var path: Path?
    var time = 0, length = 0.0
    
    init() {
        databaseRef = Database.database().reference()
    }
    
    func startTrip() {
        databaseRef = Database.database().reference().child(Firebase.Table.Paths).childByAutoId()
        path = Path()
        path?.pathID = databaseRef?.key
        if let pathId = path?.pathID {
            ManagePathManager.sharedinstance.addInitialPath(pathID: pathId)
        }
    }
    
    func saveDriveInformation(completion: @escaping () -> Void) {
        guard let pathId = path?.pathID else {
            completion()
            return
        }
        
        ManagePathManager.sharedinstance.addEndpath(pathId: pathId)
        
        let userId = Auth.auth().currentUser?.uid ?? ""
        // insert date code and add date to to dict
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.string(from: Date.now)
        // upload spot
        
        
        let pathDict = ["UserId": userId, "pathName": "New path", "pathID": pathId, "time": String(format: "%.1d", self.time / 60), "distance": String(describing: self.length), "createdDate": date] as [String: Any]
        
        //MARK: - NEW FUNC SPOT ADDED
        if var spList = path?.spotArray, !spList.isEmpty {
            for index in 0..<spList.endIndex {
                let spotRef = Database.database().reference().child(Firebase.Table.SpotList).childByAutoId()
                spList[index].id = spotRef.key
                if let spotId = spList[index].id {
                    Database.database().reference().child(Firebase.Table.Paths).child(pathId).child(Firebase.Table.SpotList).updateChildValues([spotId: "id"])
                }
                var spotDict = ["spotId": spList[index].id as Any, "description": spList[index].spotDescription ?? ""]
                if let lat = spList[index].location?.coordinate.latitude,
                    let lng = spList[index].location?.coordinate.longitude,
                    let cat = spList[index].cat {
                    spotDict["lat"] = "\(lat)"
                    spotDict["long"] = "\(lng)"
                    spotDict["category"] = cat
                }
                if let spotId = spList[index].id {
                    Database.database().reference().child(Firebase.Table.SpotList).child(spotId).updateChildValues(spotDict)
                }
                
                if let img = spList[index].spotSelectedImage, let spotId = spList[index].id {
                    let data = img.jpegData(compressionQuality: 0.8)
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    let imagename = Firebase.Folder.SpotImages + "\(spotId).jpeg"
                    storageRef = storageRef.child(imagename)
                    storageRef.putData(data!,metadata: metaData) { [weak self] (_, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        self?.storageRef.downloadURL { url, error in
                            let spotImageUrl = url?.absoluteString
                            if let spotId = spList[index].id {
                                Database.database().reference().child(Firebase.Table.SpotList).child(spotId).updateChildValues(["spotImageUrl": spotImageUrl as Any])
                            }
                            spList[index].spotImageUrl = spotImageUrl
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            self.path?.spotArray = spList
        }
        
        self.databaseRef?.updateChildValues(pathDict, withCompletionBlock: { (error, ref) in
            if let key = ref.key {
                Database.database().reference().child(Firebase.Table.Users).child(userId).child(Firebase.Table.Paths).updateChildValues([key: "id"])
            }
            completion()
        })
    }
    
    func getBearingBetweenTwoPoints(_ point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = point1.coordinate.latitude.degreesToRadians()
        let lon1 = point1.coordinate.longitude.degreesToRadians()
        
        let lat2 = point2.coordinate.latitude.degreesToRadians()
        let lon2 = point2.coordinate.longitude.degreesToRadians()
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing.radiansToDegrees()
    }
    
    func removeSpot(at index: Int) {
        let spot = path?.spotArray[index]
        path?.spotArray.remove(at: index)
        let ref = Database.database().reference()
        ref.child(Firebase.Table.Paths).child((path?.pathID)!).child(Firebase.Table.SpotList).child((spot?.id)!).removeValue()
        ref.child(Firebase.Table.SpotList).child((spot?.id)!).removeValue()
    }
}

