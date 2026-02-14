//
//  URButtonStyle.swift
//  Firebase Roader Demo
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI

struct URPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundStyle(.white)
            .font(.headline)
            .padding()
            .frame(height: 40)
            .background(Theme.themeColor)
            .clipShape(.capsule)
    }
}

struct URSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundStyle(Theme.themeColor)
            .font(.headline)
            .padding()
            .frame(height: 40)
            .background(.white.opacity(0.7))
            .clipShape(.capsule)
            .overlay {
                Capsule()
                    .stroke(Theme.themeColor, lineWidth: 2)
            }
    }
}

extension ButtonStyle where Self == URPrimaryButtonStyle {
    static var URPrimary: URPrimaryButtonStyle { URPrimaryButtonStyle() }
}

extension ButtonStyle where Self == URSecondaryButtonStyle {
    static var URSecondary: URSecondaryButtonStyle { URSecondaryButtonStyle() }
}

#Preview {
    VStack(spacing: 40) {
        Button("Press me") {
            
        }
        .buttonStyle(.URPrimary)
        
        Button("Press me") {
            
        }
        .buttonStyle(.URSecondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
