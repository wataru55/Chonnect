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
                        NavigationLink {
                            ProfileView(user: follower.record.user, currentUser: viewModel.currentUser, date: follower.record.date,
                                        isShowFollowButton: false, isShowDateButton: false)
                        } label: {
                            UserRowView(user: follower.record.user, tags: follower.tags,
                                        date: nil, isRead: true, rssi: nil, isFollower: follower.isFollowed)
                        }
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
