//
//  CircleimageView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/21.
//

import SwiftUI
import Kingfisher

enum ProfileImageSize {
    case xsmall
    case small
    case medium
    case large

    var dimension: CGFloat {
        switch self {
        case .xsmall:
            return 40
        case .small:
            return 48
        case .medium:
            return 70
        case .large:
            return 90
        }
    }
}

struct CircleImageView: View {
    let user: User
    let size: ProfileImageSize
    let borderColor: Color

    var body: some View {
        if let imageUrl = user.backgroundImageUrl {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(Color(borderColor), lineWidth: 1)
                    }
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
                    .foregroundColor(Color(.systemGray4))
            }
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
                .foregroundColor(Color(.systemGray4))
        }
    }
}

#Preview {
    CircleImageView(user: User.MOCK_USERS[0], size: .large, borderColor: .clear)
}
