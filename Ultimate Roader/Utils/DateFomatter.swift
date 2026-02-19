//
//  DateFomatter.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/19/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation

struct URDateFomatter {
    static let dateFormatter = DateFormatter()
    
    static func string(from date: Date?) -> String? {
        dateFormatter.dateFormat = "dd MMM, yyyy"
        
        if let date {
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
}
