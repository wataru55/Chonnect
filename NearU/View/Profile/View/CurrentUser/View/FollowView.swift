//
//  ConnectedSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.
//

import SwiftUI

struct FollowView: View {
    @EnvironmentObject var viewModel: FollowViewModel

    var currentUser: User

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.followUsers.isEmpty {
                    NothingDataView(text: "フォローしているユーザーがいません",
                                    explanation: "ここでは、あなたがフォローしたユーザーの一覧が表示されます。",
                                    isSystemImage: true,
                                    isAbleToReload: true)

                } else {
                    ForEach(viewModel.followUsers, id: \.self) { followUser in
                        NavigationLink {
                            ProfileView(user: followUser.pairData.user, currentUser: currentUser, date: followUser.pairData.date,
                                        isShowFollowButton: true, isShowDateButton: true)
                        } label: {
                            UserRowView(user: followUser.pairData.user, tags: followUser.pairData.user.interestTags,
                                        date: followUser.pairData.date, rssi: nil, isFollower: followUser.isFollowed)
                        }
                    }//foreach
                }
            }//lazyvstack
            .padding(.top, 8)
            .padding(.bottom, 100)

        }//scrollview
        .refreshable {
            Task {
                await viewModel.loadFollowedUsers()
            }
        }
    }
}

#Preview {
    FollowView(currentUser: User.MOCK_USERS[0])
        .environmentObject(FollowViewModel())
}
