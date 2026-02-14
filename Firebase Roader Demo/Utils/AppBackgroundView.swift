//
//  AppBackgroundView.swift
//  Firebase Roader Demo
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI

struct AppBackgroundView: ViewModifier {
    let imageName: String
    func body(content: Content) -> some View {
        ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 4)
                .ignoresSafeArea()
            
            content
        }
    }
}

extension View {
    func appBackground(name: String = "Intro_screen") -> some View {
        self
            .modifier(AppBackgroundView(imageName: name))
    }
}

#Preview {
    Text("Hello World!")
        .appBackground()
}
