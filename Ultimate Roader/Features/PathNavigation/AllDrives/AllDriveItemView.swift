//
//  AllDriveItemView.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/16/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI

struct AllDriveItemView: View {
    let path: Path
    var onSelectFollowers: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 12) {
                Image(modeIconName)
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 6) {
                    Text(path.pathName ?? "-")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Text(path.dateForDisplay ?? "")
                }
            }
            otherDetails
        }
        .font(.footnote)
        .foregroundStyle(.gray)
    }
    
    private var otherDetails: some View {
        HStack(spacing: 8) {
            HStack {
                Spacer()
                VStack {
                    Image("total_distance")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("\(distanceString) km")
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                VStack {
                    Image("time")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("\(timeString) mins")
                }
                Spacer()
            }

            Button {
                onSelectFollowers?()
            } label: {
                // TODO: Remove iOS 26
                if #available(iOS 26.0, *) {
                    HStack {
                        Spacer()
                        VStack {
                            Image("follower")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("\(path.followed_user.keys.count)")
                        }
                        Spacer()
                    }
                    .glassEffect()
                    .contentShape(.rect)
                } else {
                    HStack {
                        Spacer()
                        VStack {
                            Image("follower")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("\(path.followed_user.keys.count)")
                        }
                        Spacer()
                    }
                    .background(.white.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 4))
                    .contentShape(.rect)
                }
            }
            .buttonStyle(.borderless)
            .disabled(onSelectFollowers == nil || path.pathType == PathType.private)
            .opacity(path.pathType != PathType.private ? 1 : 0)
        }
        .padding(.vertical, 4)
    }
}

// MARK: View Model
extension AllDriveItemView {
    private var distanceString: String {
        if let d = Double(path.distance ?? "0") { return String(format: "%.01f", d) }
        return "0.0"
    }
    
    private var timeString: String { path.time ?? "1" }
    
    private var modeIconName: String {
        switch path.difficulty.rawValue {
        case "hard": return "HardPathmodeIconSec"
        case "medium": return "MediumPathModeIconSec"
        case "easy": return "EasyPathModeIconSec"
        default: return "MediumPathModeIconSec"
        }
    }
}

#Preview {
    @Previewable @State var path = Path(withDict: [
        "pathName": "My first path",
        "distance": "10.0",
        "time": "10",
        "difficulty": "easy",
        "UserId": "12345",
        "pathType": "public",
        "pathID": "1234567890",
        "createdDate": "2026-02-19T15:59:19Z"
    ])
    
    VStack {
        AllDriveItemView(path: path)
    }
    .appBackground()
}
