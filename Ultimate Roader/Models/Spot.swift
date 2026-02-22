//
//  Spot.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 11/11/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase

enum Icon {
    enum Version: String {
        case Small = "small"
        case Medium = "medium"

        var name: String { return self.rawValue }
    }
}

extension Path {
    struct Spot {
        enum Category: String, CaseIterable {
            case Scenic
            case Lake
            case Hill
            case Mountain
            case Beach
            case Gyser
            case Water
            case General
            case Icon = "icon"
        }
        
        var id: String?
        var spotDescription : String? = ""
        var location : CLLocation?
        var spotImageUrl : String?
        var cat : String?
        var spotSelectedImage: UIImage?
        
        init(withSnap snapshot: DataSnapshot) {
            self.init()
            guard let dict = snapshot.value as? [String: Any] else { return }
            guard let decoded = try? FirebaseCodable.decode(Path.Spot.self, from: dict) else { return }
            self = decoded
        }
        
//        override required
        init() {
            //super.init()
        }
    }
}

extension Path.Spot: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "spotId"
        case spotDescription = "description"
        case cat = "category"
        case lat
        case long
        case spotImageUrl
    }

    init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        spotDescription = try container.decodeIfPresent(String.self, forKey: .spotDescription)
        cat = try container.decodeIfPresent(String.self, forKey: .cat)
        spotImageUrl = try container.decodeIfPresent(String.self, forKey: .spotImageUrl)

        let latitude = try container.decodeIfPresent(LossyDouble.self, forKey: .lat)?.value
        let longitude = try container.decodeIfPresent(LossyDouble.self, forKey: .long)?.value
        if let latitude, let longitude {
            location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}




