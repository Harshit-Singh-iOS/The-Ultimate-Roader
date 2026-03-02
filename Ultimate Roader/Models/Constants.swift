//
//  SwiftAlertBar.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 10/26/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import SwiftUI

struct Theme {
    static let barConfig = MessageBarConfig.Builder()
        .withErrorColor(.black)
        .withSuccessColor(Theme.uiThemeColor)
        .withInfoColor(.gray)
        .build()
    
    static let barConfig2 = MessageBarConfig.Builder()
    
    
    static let uiThemeColor = UIColor(named: "themeColor")!
    static let uiPathColor = UIColor(named: "pathColor")!
    static let uiPathColor2 = UIColor(named: "themeColor")!
    
    static let themeColor = Color("themeColor")
    static let pathColor = Color("pathColor")
    static let pathColor2 = Color("themeColor")
    
    static let pathWidth: CGFloat = 8
}

struct LoginConstants {
    static let em = "harrysingh1715@gmail.com"
    static let pass = "Qwerty@1234"
}

struct Constants {
    static let kWEATHERAPIKEY = "b27b1cfe499c89d6e8db7f668d48275f"
    static let kGoogleClientId = "315488888774-6d2q9kvf1phj511pmnskptu441n9e0a9.apps.googleusercontent.com"
    
    static var animationImage: [UIImage] = {
        var imageArr : Array<UIImage> = []
        for i in 1...44 {
            imageArr.append(UIImage(named : "Anim 2_\(i)")!)
        }
        return imageArr
    }()
}
