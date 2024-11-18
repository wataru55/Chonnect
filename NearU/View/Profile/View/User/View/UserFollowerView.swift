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
                        UserRowView(value: follower.record, user: follower.record.user, date: nil, isRead: nil, rssi: nil, isFollower: follower.isFollowed)
                    } //foreach
                }
            } //lazyvstack
            .padding(.top, 8)
            .navigationDestination(for: UserHistoryRecord.self, destination: { follower in
                ProfileView(user: follower.user, currentUser: viewModel.currentUser, date: follower.date, isShowFollowButton: false)
            })

        } //scrollview
        .refreshable {
            print("refresh")
        }
    }
}

//#Preview {
//    UserFollowerView()
//}
