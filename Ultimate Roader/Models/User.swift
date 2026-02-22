//
//  User.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 10/18/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class User: Decodable {
    
    var firstname: String?
    var lastname: String?
    var city: String?
    var email: String?
    var password: String?
    var userImageUrl: String?
    var userID: String?
    var pathList: [String:Any] = [:]

    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case firstname = "FirstName"
        case lastname = "LastName"
        case city = "City"
        case email = "EmailID"
        case password = "Password"
        case userImageUrl
        case pathList = "Paths"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        firstname = try container.decodeIfPresent(String.self, forKey: .firstname)
        lastname = try container.decodeIfPresent(String.self, forKey: .lastname)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        userImageUrl = try container.decodeIfPresent(String.self, forKey: .userImageUrl)

        if let decodedPaths = try container.decodeIfPresent([String: AnyCodable].self, forKey: .pathList) {
            pathList = decodedPaths.mapValues(\.value)
        } else {
            pathList = [:]
        }
    }

    init(withsnap snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return }
        guard let decoded = try? FirebaseCodable.decode(User.self, from: dict) else { return }
        copy(from: decoded)
    }
    
    init(withDict dict_user: [String:Any]) {
        guard let decoded = try? FirebaseCodable.decode(User.self, from: dict_user) else { return }
        copy(from: decoded)
    }

    private func copy(from user: User) {
        userID = user.userID
        firstname = user.firstname
        lastname = user.lastname
        city = user.city
        email = user.email
        password = user.password
        userImageUrl = user.userImageUrl
        pathList = user.pathList
    }
}

typealias handler = (Any?) -> ()

class ManipulateUser: NSObject {
    private override init() {}
    static var sharedinstance = ManipulateUser()
    
     func getUser(completion: @escaping handler){
        var user: User?
        let ref: DatabaseReference = Database.database().reference()
        let u = Auth.auth().currentUser
        
        ref.child(Firebase.Table.Users).child((u?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            user = User(withsnap: snapshot)
            completion(user)
        }
    }
    
    static func getPathNameList(completion: @escaping handler) {
        let ref: DatabaseReference = Database.database().reference()
        let u = Auth.auth().currentUser
        
        ref.child(Firebase.Table.Users).child((u?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Any],
                  let user = try? FirebaseCodable.decode(User.self, from: dict)
            else {
                completion(nil)
                return
            }

            if user.pathList.isEmpty {
                completion(nil)
            } else {
                completion(user.pathList)
            }
        }
    }
    
    static func getUserForpath(path: Path, completion: @escaping handler) {
        guard let userlist = path.followed_user as? [String:String] else {
            completion(nil)
            return
        }
        
        let ref: DatabaseReference = Database.database().reference()
        var userObjlist: [User] = []
        var allObjList: [String: User] = [:]
        
        ref.child(Firebase.Table.Users).observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? [String:Any] {
                for v in val {
                    if let dict = v.value as? Dictionary<String,Any> {
                        allObjList[v.key] = User(withDict: dict)
                    }
                }
                for user_key in userlist.keys {
                    userObjlist.append(allObjList[user_key]!)
                }
                completion(userObjlist)
            } else {
                completion(nil)
            }
        }

        for user in userlist.keys {
            ref.child(Firebase.Table.Users).child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                userObjlist.append(User(withsnap: snapshot))
                if userObjlist.count == userlist.keys.count {
                    completion(userObjlist)
                }
            })
        }
        completion(userObjlist)
    }
}
