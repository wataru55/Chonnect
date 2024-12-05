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
                    Text("フォローされているユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.followers, id: \.self) { follower in
                        NavigationLink {
                            ProfileView(user: follower.record.user, currentUser: currentUser, date: follower.record.date,
                                        isShowFollowButton: true, isShowDateButton: true)
                                .onAppear {
                                    Task {
                                        await viewModel.updateRead(userId: follower.record.user.id)
                                    }
                                }
                        } label: {
                            UserRowView(user: follower.record.user, tags: follower.tags,
                                        date: follower.record.date, isRead: follower.record.isRead,
                                        rssi: nil, isFollower: false)
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
