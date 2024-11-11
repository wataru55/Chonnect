//
//  BackgroundImageView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/09/29.
//

import SwiftUI
import Kingfisher

struct BackgroundImageView: View {
    let user: User
    let height: CGFloat
    let isGradient: Bool

    var body: some View {
        if let imageUrl = user.backgroundImageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: height)
                .clipped()
                .overlay(
                    Group {
                        if isGradient {
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0), location: 0.5),
                                    .init(color: Color(red: 0.96, green: 0.97, blue: 0.98).opacity(1), location: 1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color.clear // グラデーションが不要な場合は透明なビューを重ねる
                        }
                    }
                )
        } else {
            RoundedRectangle(cornerRadius: 0)
                .frame(width: UIScreen.main.bounds.width, height: height)
                .foregroundColor(Color(.systemGray4))
                .overlay {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                   
                        .foregroundColor(.white)
                }
        }
    }
}

#Preview {
    BackgroundImageView(user: User.MOCK_USERS[0], height: 500, isGradient: true)
}
