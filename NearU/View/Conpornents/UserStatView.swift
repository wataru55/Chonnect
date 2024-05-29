//
//  UserStatView.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/04/30.
//

import SwiftUI

struct UserStatView: View {
    //MARK: - property
    let count: Int
    let title: String

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.bold)

            Text(title)
                .font(.subheadline)
        }
    }
}

#Preview {
    UserStatView(count: 3, title: "Posts")
}
