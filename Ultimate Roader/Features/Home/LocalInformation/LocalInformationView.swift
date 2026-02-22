//
//  LocalInformationView.swift
//  Ultimate Roader
//
//  Created by Assistant on 2/15/26.
//

import SwiftUI

struct LocalInformationView: View {
    @State private var vm = LocalInformationViewModel()
    @State private var heading: CGFloat = 0

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
        .task { vm.updateHeading = updateHeading }
        .onAppear(perform: vm.startUpdatingHeading)
        .onDisappear(perform: vm.stopUpdatingHeading)
    }
    
    private var compassView: some View {
        ZStack {
            Image("compassCircle")
                .resizable()
                .scaledToFit()
                
            Image("compassNeedleNorth")
                .resizable()
                .scaledToFit()
        }
        .rotationEffect(.radians(Double(heading)))
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
    
    private func updateHeading(_ heading: CGFloat) {
        withAnimation(.smooth) {
            self.heading = heading
        }
    }
}

#Preview {
    NavigationStack { LocalInformationView() }
}
