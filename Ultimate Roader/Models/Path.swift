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

struct Path: Decodable {
    var pathID: String?
    var time: String?
    var distance: String?
    var pathName: String?
    var createdDate: Date?
    var followed_user: Dictionary<String,Any> = [:]
    var pathType: String = PathType.private
    var difficulty: PathDifficulty = .Easy
    var track: Array<CLLocation> = []
    var spotArray: [Spot] = []
    var spotDict: [String:String] = [:]
    var userId: String?
    
    var dateForDisplay: String? {
        URDateFomatter.string(from: createdDate) ?? nil
    }
    
    init(withsnap snapshot: DataSnapshot) {
        self.init()
        guard let dict = snapshot.value as? [String: Any] else { return }
        guard let decoded = try? FirebaseCodable.decode(Path.self, from: dict) else { return }
        self = decoded
    }
    
    init(withDict dict: Dictionary<String,Any>) {
        self.init()
        guard let decoded = try? FirebaseCodable.decode(Path.self, from: dict) else { return }
        self = decoded
    }
    
    init() { }

    enum CodingKeys: String, CodingKey {
        case pathID
        case time
        case distance
        case pathName
        case createdDate
        case followedUser = "FollowedUsers"
        case pathType
        case difficulty
        case spotDict = "SpotList"
        case userId = "UserId"
    }

    init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        pathID = try container.decodeIfPresent(String.self, forKey: .pathID)
        time = try container.decodeIfPresent(String.self, forKey: .time)
        distance = try container.decodeIfPresent(String.self, forKey: .distance)
        pathName = try container.decodeIfPresent(String.self, forKey: .pathName)
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
        pathType = try container.decodeIfPresent(String.self, forKey: .pathType) ?? PathType.private
        difficulty = try container.decodeIfPresent(PathDifficulty.self, forKey: .difficulty) ?? .Easy
        spotDict = try container.decodeIfPresent([String: String].self, forKey: .spotDict) ?? [:]
        userId = try container.decodeIfPresent(String.self, forKey: .userId)

        if let followed = try container.decodeIfPresent([String: AnyCodable].self, forKey: .followedUser) {
            followed_user = followed.mapValues(\.value)
        }
    }
}


enum PathDifficulty: String, Codable {
    case Easy = "easy"
    case Medium = "medium"
    case Hard = "hard"
    static let allValues: [PathDifficulty] = [.Easy, .Medium, .Hard]
}

enum PathType {
    static let `public`: String = "public"
    static let `private`: String = "private"
    static let allValues: [String] = [PathType.public, PathType.private]
}
