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
        databaseRef = Database.database().reference().child("Paths").childByAutoId()
        path = Path()
        path?.pathID = databaseRef?.key
        if let pathId = path?.pathID {
            ManagePathManager.sharedinstance.addInitialPath(pathID: pathId)
        }
    }
    
    func createPathTableInFire(completion: @escaping () -> Void) {
        let userId = Auth.auth().currentUser?.uid ?? ""
        // insert date code and add date to to dict
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let date = dateFormatter.string(from: Date())
        // upload spot
        
        
        let pathDict = ["UserId": userId, "pathName": "New path", "pathID": self.path?.pathID ?? "", "time": String(format: "%.1d", self.time / 60), "distance": String(describing: self.length), "date": date] as [String: Any]
        
        //MARK: - NEW FUNC SPOT ADDED
        if let spList = path?.spotArray, !spList.isEmpty {
            for spot in spList {
                let spotRef = Database.database().reference().child("SpotList").childByAutoId()
                spot.id = spotRef.key
                if let pathId = path?.pathID, let spotId = spot.id {
                    Database.database().reference().child("Paths").child(pathId).child("SpotList").updateChildValues([spotId: "id"])
                }
                var spotDict = ["spotId": spot.id as Any, "description": spot.spotDescription ?? ""]
                if let lat = spot.location?.coordinate.latitude, let lng = spot.location?.coordinate.longitude, let cat = spot.cat {
                    spotDict["lat"] = "\(lat)"
                    spotDict["long"] = "\(lng)"
                    spotDict["category"] = cat
                }
                if let spotId = spot.id {
                    Database.database().reference().child("SpotList").child(spotId).updateChildValues(spotDict)
                }
                
                if let img = spot.spotImage, let spotId = spot.id {
                    let data = img.jpegData(compressionQuality: 0.8)
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    let imagename = "SpotImage/\(spotId).jpeg"
                    storageRef = storageRef.child(imagename)
                    storageRef.putData(data!,metadata: metaData) { [weak self] (_, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        self?.storageRef.downloadURL { url, error in
                            let spotImageUrl = url?.absoluteString
                            if let spotId = spot.id {
                                Database.database().reference().child("SpotList").child(spotId).updateChildValues(["spotImageUrl": spotImageUrl as Any])
                            }
                            spot.spotImageUrl = spotImageUrl
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
        
        self.databaseRef?.updateChildValues(pathDict, withCompletionBlock: { (error, ref) in
            if let key = ref.key {
                Database.database().reference().child("Users").child(userId).child("Paths").updateChildValues([key: "id"])
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
        ref.child("Paths").child((path?.pathID)!).child("SpotList").child((spot?.id)!).removeValue()
        ref.child("SpotList").child((spot?.id)!).removeValue()
    }
}

extension Double {
    func degreesToRadians() -> Double { return self * Double.pi / 180.0 }
    func radiansToDegrees() -> Double { return self * 180.0 / Double.pi }
}
