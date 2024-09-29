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

    var body: some View {
        if let imageUrl = user.backgroundImageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width - 20, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 10))

        } else {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.main.bounds.width - 20, height: 250)
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
    BackgroundImageView(user: User.MOCK_USERS[0])
}
