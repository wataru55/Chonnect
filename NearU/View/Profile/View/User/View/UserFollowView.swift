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
                        NavigationLink {
                            ProfileView(user: followUser.pair.user, currentUser: viewModel.currentUser, date: followUser.pair.date,
                                        isShowFollowButton: false, isShowDateButton: false)
                        } label: {
                            UserRowView(user: followUser.pair.user, tags: followUser.pair.user.interestTags,
                                        date: nil, isRead: true,rssi: nil, isFollower: followUser.isFollowed)
                        }
                    }//foreach
                }
            }//lazyvstack
            .padding(.top, 8)
            .padding(.bottom, 100)

        }//scrollview
        .refreshable {
            print("refresh")
        }
    }
}

//#Preview {
//    UserFollowView(viewModel: ProfileViewModel())
//}
