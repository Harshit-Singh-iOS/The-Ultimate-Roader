//
//  LocalInformationView.swift
//  Ultimate Roader
//
//  Created by Assistant on 2/15/26.
//

import SwiftUI

struct LocalInformationView: View {
    @State private var vm = LocalInformationViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Text(vm.directionText)
                    .font(.title2)
                    .foregroundStyle(.white)
                
                compassView
                weatherView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay {
            if vm.isLoading { ProgressView().tint(Theme.themeColor) }
        }
    }
    
    private var compassView: some View {
        ZStack {
            Image("compassCircle")
                .resizable()
                .scaledToFit()
                .rotationEffect(.radians(Double(vm.headingRadians)))
            
            Image("compassNeedleNorth")
                .resizable()
                .scaledToFit()
                .rotationEffect(.radians(Double(vm.headingRadians)))
        }
    }
    
    private var weatherView: some View {
        Group {
            HStack(spacing: 24) {
                Image(uiImage: vm.weatherImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text(vm.temperatureText)
                    .font(.largeTitle)
                    .bold()
            }
            
            Text(vm.placeText)
                .font(.largeTitle)
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    NavigationStack { LocalInformationView() }
}
