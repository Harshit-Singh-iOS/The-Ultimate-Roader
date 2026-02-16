//
//  AppBackgroundView.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI

enum AppBackground: String {
    case PreLogin = "Intro_screen"
    case PostLogin = "PostLoginBackground"
}

struct AppBackgroundView: ViewModifier {
    let imageName: String
    let blur: CGFloat
    
    func body(content: Content) -> some View {
        ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: blur)
                .ignoresSafeArea()
            
            content
        }
    }
}

extension View {
    func appBackground(_ image: AppBackground = .PostLogin) -> some View {
        self
            .modifier(AppBackgroundView(imageName: image.rawValue, blur: image == .PreLogin ? 4 : 0))
    }
}

#Preview {
    Text("Hello World!")
        .appBackground()
}
