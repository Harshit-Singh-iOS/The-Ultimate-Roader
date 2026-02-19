//
//  Path.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 10/22/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

struct Path {
    var pathID: String?
    var time: String?
    var distance: String?
    var pathName: String?
    var createdDate: Date?
    var followed_user: Dictionary<String,Any> = [:]
    var pathType: PathType = .Private
    var difficulty: Difficulty = .Easy
    var track: Array<CLLocation> = []
    var spotArray: [Spot] = []
    var spotDict: [String:String] = [:]
    var userId: String?
    
    var dateForDisplay: String? {
        URDateFomatter.string(from: createdDate) ?? nil
    }
    
    init(withsnap snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? Dictionary<String,Any> else { return }
        pathName = dict["pathName"] as? String
        pathID = dict["pathID"] as? String
        time = dict["time"] as? String
        distance = dict["distance"] as? String
        if let createdDate = dict["createdDate"] as? String {
            self.createdDate = ISO8601DateFormatter().date(from: createdDate)
        }
        userId = dict["UserId"] as? String
        if let follow_dict = dict["FollowedUsers"] as? [String:Any] {
            followed_user = follow_dict
        }
        
        if let path_type = dict["pathType"] as? String {
            self.pathType = PathType(rawValue: path_type) ?? .Private
        }
        if let difficulty = dict["difficulty"] as? String {
            self.difficulty = Difficulty(rawValue: difficulty) ?? .Easy
        }
        if let d = dict["SpotList"] as? [String:String] {
            spotDict = d
        }
    }
    
    init(withDict dict: Dictionary<String,Any>) {
        pathName = dict["pathName"] as? String
        pathID = dict["pathID"] as? String
        time = dict["time"] as? String
        distance = dict["distance"] as? String
        if let createdDate = dict["createdDate"] as? String {
            self.createdDate = ISO8601DateFormatter().date(from: createdDate)
        }
        userId = dict["UserId"] as? String
        spotArray = []
        if let follow_dict = dict["FollowedUsers"] as? [String:Any] {
            followed_user = follow_dict
        }
        if let path_type = dict["pathType"] as? String {
            self.pathType = PathType(rawValue: path_type) ?? .Private
        }
        if let difficulty = dict["difficulty"] as? String {
            self.difficulty = Difficulty(rawValue: difficulty) ?? .Easy
        }
        if let d = dict["SpotList"] as? [String:String] {
            spotDict = d
        }
    }
    
    enum Difficulty: String {
        case Easy = "easy"
        case Medium = "medium"
        case Hard = "hard"
        static let allValues: [Difficulty] = [.Easy, .Medium, .Hard]
    }
    
    enum PathType: String {
        case Public = "public"
        case Private = "private"
        static let allValues: [PathType] = [.Public, .Private]
    }
    
    init() { }
}

