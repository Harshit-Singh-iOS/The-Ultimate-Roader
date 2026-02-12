//
//  SwiftAlertBar.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/26/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit

struct Theme {
    static let barConfig = MessageBarConfig.Builder()
        .withErrorColor(.black)
        .withSuccessColor(Theme.theme_color)
        .withInfoColor(.gray)
        .build()
    
    static let barConfig2 = MessageBarConfig.Builder()
    
    static let path_color = UIColor(red: 0.0/255.0, green: 255.0/255, blue:230.0/255, alpha: 1.0)
    static let theme_color = UIColor(red: 0.793583, green: 0.141524, blue: 0.284081, alpha: 1)
    
    static let pathWidth: CGFloat = 8
}

struct LoginConstants {
    static let em = "hs@gmail.com"
    static let pass = "Qwerty@1234"
}

struct Constants {
    static let kWEATHERAPIKEY = "b27b1cfe499c89d6e8db7f668d48275f"
    static let kGoogleClientId = "315488888774-6d2q9kvf1phj511pmnskptu441n9e0a9.apps.googleusercontent.com"
}
