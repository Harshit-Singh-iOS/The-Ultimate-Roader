//
//  FirebaseSchema.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/21/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation

enum Firebase {
    enum Table {
        static let Paths: String = "Paths"
        static let SpotList: String = "SpotList"
        static let Users: String = "Users"
    }

    enum Folder {
        static let PathFiles: String = "PathFiles/"
        static let SpotImages: String = "SpotImages/"
        static let UserImages: String = "UserImages/"
    }
}
