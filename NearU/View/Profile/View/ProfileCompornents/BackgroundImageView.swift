//
//  BackgroundImageView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/09/29.
//

import Kingfisher
import SwiftUI

struct BackgroundImageView: View {
    let imageUrl: String?
    let height: CGFloat
    let isGradient: Bool

    var body: some View {
        if let url = imageUrl {
            KFImage(URL(string: url))
                .placeholder {
                    ProgressView()
                }
                .fade(duration: 0.5)  // フェードインアニメーション
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
                                    .init(
                                        color: Color(red: 0.96, green: 0.97, blue: 0.98).opacity(1),
                                        location: 1),
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color.clear  // グラデーションが不要な場合は透明なビューを重ねる
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
    BackgroundImageView(
        imageUrl: User.MOCK_USERS[0].backgroundImageUrl, height: 500, isGradient: true)
}
