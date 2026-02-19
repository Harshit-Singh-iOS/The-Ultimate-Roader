//
//  ManagePathManager.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

typealias completionhandler = (Any) -> ()

class ManagePathManager: NSObject {
    
    var doc_url: URL?
    var file_url: URL?
    var first = true
    let fileManager = FileManager.default
    var fileHandle: FileHandle?
    
    private override init() {}
    static var sharedinstance = ManagePathManager()
    
    func addInitialPath(pathID: String) {
        first = true
        do {
            doc_url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            file_url = doc_url?.appendingPathComponent("\(pathID).json")
            let initial = ("{\"path\":[" as NSString).data(using: String.Encoding.utf8.rawValue)
            if let url = file_url {
                if fileManager.fileExists(atPath: (url.path)) {
                    fileHandle = FileHandle(forUpdatingAtPath: (url.path))
                } else if fileManager.createFile(atPath: (url.path), contents: initial, attributes: nil) {
                    fileHandle = FileHandle(forWritingAtPath: (url.path))
                }
            }
        }
        catch let error as NSError{
            print(error.description)
        }
        
    }
    
    func addEndpath(pathId: String) {
        fileHandle?.seekToEndOfFile()
        fileHandle?.write("]}".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
        try? fileHandle?.close()
        fileHandle = nil
        
        // Upload path file to firebase
        var storageRef = Storage.storage().reference()
        guard let url = file_url else { return }
        
        do {
            let data: Data = try Data(contentsOf: url)
            let metaData = StorageMetadata()
            metaData.contentType = "text"
            
            let file_name = "PathFiles/\(String(describing: pathId)).txt"
            storageRef = storageRef.child(file_name)
            
            storageRef.putData(data,metadata: metaData) { (data, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Error")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addCordinateTopath(latidude: Double, longitude: Double) {
        
        fileHandle?.seekToEndOfFile()
        if first {
            let data = "{\"latitude\":\"\(latidude)\", \"longitude\":\"\(longitude)\"}"
            fileHandle?.write(data.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
            first = false
        } else {
            let data = ",{\"latitude\":\"\(latidude)\", \"longitude\":\"\(longitude)\"}"
            fileHandle?.write(data.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
        }
    }
    
    func getUsersPaths(completion: @escaping handler) {
        var pathNameList: [String:Any] = [:]
        var pathObjList: [Path] = []
        ManipulateUser.getPathNameList { (list) in
            if let path_list = list as? [String:Any] {
                pathNameList = path_list
            }
            
            let databaseRef = Database.database().reference()
            var path: Path?
            
            for name in pathNameList.keys {
                databaseRef.child("Paths").child(name).observeSingleEvent(of: .value) { (snapshot) in
                    path = Path(withsnap: snapshot)
                    pathObjList.append(path!)
                    if pathObjList.count == pathNameList.count {
                        completion(pathObjList)
                    }
                }
            }
            completion(pathObjList)
        }
    }
    
    func getAllPublicPaths(completion: @escaping handler) {
        let databaseRef = Database.database().reference()
        databaseRef.child("Paths").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Dictionary<String,Any> {
                var path_list: [Path] = []
                for v in val {
                    if let path_dict = v.value as? Dictionary<String,Any> {
                        if let ptype = path_dict["pathType"] as? String {
                            if ptype == "public" {
                                path_list.append(Path(withDict: path_dict))
                            }
                        }
                    }
                }
                completion(path_list)
            } else {
                completion([])
            }
        }
    }
    
    func getPathFromFile(name: String, completion: @escaping handler){
        var storageRef = Storage.storage().reference()
        var path: [CLLocation] = []
        
        let file_name = "PathFiles/\(String(describing: name)).txt"
        storageRef = storageRef.child(file_name)
        
        storageRef.getData(maxSize: 1024*1024*1024) { (data, error) in
            guard let path_data = data else {
                print(error)
                completion(nil)
                return
            }
            
            do {
                if let path_json = try JSONSerialization.jsonObject(with: path_data, options: []) as? Dictionary<String,Any>,
                   let new_path = path_json["path"] as? [Dictionary<String,String>] {
                    
                    for cord in new_path {
                        let lat = Double(cord["latitude"]!)
                        let long = Double(cord["longitude"]!)
                        let c = CLLocation(latitude: lat!, longitude: long!)
                        path.append(c)
                    }
                    completion(path)
                    
                } else {
                    completion(nil)
                }
            } catch {
                print(error)
                completion(nil)
            }
        }
        
        
        // MARK: - Save to local
        //        do {
        //            doc_url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        //            guard let newFileURL = doc_url?.appendingPathComponent("\(name).json") else {
        //                return
        //            }
        //            let jsonData = try Data(contentsOf: newFileURL)
        //            if let path_json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? Dictionary<String,Any> {
        //                if let new_path = path_json["path"] as? [Dictionary<String,String>] {
        //                    for cord in new_path {
        //
        //                        let lat = Double(cord["latitude"]!)
        //                        let long = Double(cord["longitude"]!)
        //                        let c = CLLocation(latitude: lat!, longitude: long!)
        //                        path.append(c)
        //
        //                    }
        //                    completion(path)
        //                }
        //            }
        //        } catch {
        //            print(error)
        //        }
    }
    
    func addFollowedUser(path: Path) {
        let user_dict:[String: Any] = [(Auth.auth().currentUser?.uid)!: "id"]
        let databaseRef = Database.database().reference()
        databaseRef.child("Paths").child(path.pathID!).child("FollowedUsers").updateChildValues(user_dict)
    }
    
    func deletePath(path: Path) async {
        // Remove path text file
        // Remove path from database
        // Remove path from User data
        
        let databaseRef = Database.database().reference()
        var storageRef = Storage.storage().reference()
        
        await removeSpots(for: path)
        
        // REMOVE PATH FILE
        do {
            if let pathId = path.pathID {
                try await databaseRef.child("Users").child((Auth.auth().currentUser?.uid)!).child("Paths").child(pathId).removeValue()
                try await databaseRef.child("Paths").child(pathId).removeValue()
                
                let file_name = "PathFiles/\(String(describing: pathId)).txt"
                storageRef = storageRef.child(file_name)
                try await storageRef.delete()
            }
        } catch {
            print(error)
        }
    }
    
    private func removeSpots(for path: Path) async {
        do {
            // Remove spot image from Photos
            // Remove spot from spotlist database
            let databaseRef = Database.database().reference()
            let storageRef = Storage.storage().reference()
            
            var spots = path.spotDict.map { $0.key }
            if spots.isEmpty {
                spots = path.spotArray.compactMap { $0.id }
            }
            
            for spot in spots {
                try? await storageRef.child("SpotImage").child("\(spot).jpeg").delete()
                try await databaseRef.child("SpotList").child(spot).removeValue()
            }
        } catch {
            print(error)
        }
    }
}
