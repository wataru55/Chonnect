//
//  UserFollowView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/14.
//

import SwiftUI
import Combine

struct UserFollowView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.follows.isEmpty {
                    Text("フォローしているユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.follows, id: \.self) { followUser in
                        //TODO: できたらdate, isFollowerを動的に設定
                        UserRowView(value: followUser.pair, user: followUser.pair.user, date: nil, isRead: nil, rssi: nil, isFollower: followUser.isFollowed)
                    }//foreach
                }
            }//lazyvstack
            .padding(.top, 8)
            .navigationDestination(for: UserDatePair.self, destination: { pair in
                ProfileView(user: pair.user, currentUser: viewModel.currentUser, date: pair.date, isShowFollowButton: false)
            })

        }//scrollview
        .refreshable {
            print("refresh")
        }
    }
}

//#Preview {
//    UserFollowView(viewModel: ProfileViewModel())
//}
