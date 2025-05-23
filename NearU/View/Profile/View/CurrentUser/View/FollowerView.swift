//
//  FollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import SwiftUI

struct FollowerView: View {
    @EnvironmentObject var viewModel: FollowerViewModel

    var currentUser: User

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.followers.isEmpty {
                    NothingDataView(text: "フォローされたユーザーがいません",
                                    explanation: "ここでは、あなたをフォローしたユーザーの一覧が表示されます。",
                                    isSystemImage: true,
                                    isAbleToReload: true)
                } else {
                    ForEach(viewModel.followers, id: \.self) { follower in
                        NavigationLink {
                            ProfileView(user: follower.user, currentUser: currentUser, date: follower.date,
                                        isShowFollowButton: true, isShowDateButton: true)
                        } label: {
                            UserRowView(user: follower.user, tags: follower.user.interestTags,
                                        date: follower.date, rssi: nil, isFollower: false)
                        }
                    } //foreach
                }
            } //lazyvstack
            .padding(.top, 8)
            .padding(.bottom, 100)

        } //scrollview
        .refreshable {
            Task {
                await viewModel.loadFollowers()
            }
        }
    }
}

#Preview {
    FollowerView(currentUser: User.MOCK_USERS[0])
        .environmentObject(FollowerViewModel())
}
