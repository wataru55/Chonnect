//
//  UserFollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/14.
//

import SwiftUI

struct UserFollowerView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.followers.isEmpty {
                    Text("フォローされているユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.followers, id: \.self) { follower in
                        //TODO: できたらdate, isFollowerを動的に設定
                        UserRowView(value: follower, user: follower.user, date: nil, isRead: nil, rssi: nil, isFollower: false)
                    } //foreach
                }
            } //lazyvstack
            .padding(.top, 8)

        } //scrollview
        .refreshable {
            print("refresh")
        }
    }
}

//#Preview {
//    UserFollowerView()
//}
