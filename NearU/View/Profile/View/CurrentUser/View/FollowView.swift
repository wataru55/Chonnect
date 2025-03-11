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
                    Text("フォローしているユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.followUsers, id: \.self) { followUser in
                        NavigationLink {
                            ProfileView(user: followUser.pair.user, currentUser: currentUser, date: followUser.pair.date,
                                        isShowFollowButton: true, isShowDateButton: true)
                        } label: {
                            UserRowView(user: followUser.pair.user, tags: followUser.pair.user.interestTags,
                                        date: followUser.pair.date, isRead: true,
                                        rssi: nil, isFollower: followUser.isFollowed)
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
