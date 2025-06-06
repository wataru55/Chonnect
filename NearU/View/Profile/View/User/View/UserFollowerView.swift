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
        if viewModel.isLoading {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    if viewModel.followers.isEmpty {
                        NothingDataView(text: "フォローされたユーザーがいません",
                                        explanation: "ここでは、フォローされたユーザーの一覧が表示されます。",
                                        isSystemImage: true,
                                        isAbleToReload: false)
                        
                    } else {
                        ForEach(viewModel.followers, id: \.self) { follower in
                            NavigationLink {
                                ProfileView(user: follower.pairData.user, currentUser: viewModel.currentUser,
                                            date: follower.pairData.date, isShowFollowButton: false, isShowDateButton: false)
                            } label: {
                                UserRowView(user: follower.pairData.user, tags: follower.pairData.user.interestTags,
                                            date: nil, rssi: nil, isFollower: follower.isFollowed)
                            }
                        } //foreach
                    }
                } //lazyvstack
                .padding(.top, 8)
                .padding(.bottom, 100)
                
            } //scrollview
        }
    }
}

//#Preview {
//    UserFollowerView()
//}
