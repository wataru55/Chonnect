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
                    NothingDataView(text: "フォローしたユーザーがいません",
                                    explanation: "ここでは、フォローしたユーザーの一覧が表示されます。",
                                    isSystemImage: true,
                                    isAbleToReload: false)

                } else {
                    ForEach(viewModel.follows, id: \.self) { followUser in
                        NavigationLink {
                            ProfileView(user: followUser.pairData.user, currentUser: viewModel.currentUser, date: followUser.pairData.date,
                                        isShowFollowButton: false, isShowDateButton: false)
                        } label: {
                            UserRowView(user: followUser.pairData.user, tags: followUser.pairData.user.interestTags,
                                        date: nil, rssi: nil, isFollower: followUser.isFollowed)
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
