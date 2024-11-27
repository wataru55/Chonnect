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
                        UserRowView(value: follower, user: follower.user, date: follower.date, isRead: follower.isRead, rssi: nil, isFollower: false)
                    } //foreach
                }
            } //lazyvstack
            .padding(.top, 8)
            .navigationDestination(for: UserHistoryRecord.self, destination: { follower in
                ProfileView(user: follower.user, currentUser: currentUser, date: follower.date,
                            isShowFollowButton: true, isShowDateButton: true)
                    .onAppear {
                        Task {
                            await viewModel.updateRead(userId: follower.user.id)
                        }
                    }
            })

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
