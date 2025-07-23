//
//  UserFollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/14.
//

import SwiftUI

struct UserFollowerView: View {
//    @ObservedObject var viewModel: ProfileViewModel
    let followers: [RowData]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if followers.isEmpty {
                    NothingDataView(text: "フォローされたユーザーがいません",
                                    explanation: "ここでは、フォローされたユーザーの一覧が表示されます。",
                                    isSystemImage: true,
                                    isAbleToReload: false)
                    
                } else {
                    ForEach(followers, id: \.self) { follower in
                        NavigationLink(value: follower.pairData) {
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

//#Preview {
//    UserFollowerView()
//}
