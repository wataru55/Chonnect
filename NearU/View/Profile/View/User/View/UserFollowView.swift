//
//  UserFollowView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/14.
//

import SwiftUI
import Combine

struct UserFollowView: View {
//    @ObservedObject var viewModel: ProfileViewModel
    let follows: [User]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if follows.isEmpty {
                    NothingDataView(text: "フォローしたユーザーがいません",
                                    explanation: "ここでは、フォローしたユーザーの一覧が表示されます。",
                                    isSystemImage: true,
                                    isAbleToReload: false)
                    
                } else {
                    ForEach(follows, id: \.self) { followUser in
                        NavigationLink(value: followUser) {
                            UserRowView(user: followUser, tags: followUser.interestTags,
                                        date: nil, rssi: nil)
                        }
                    }//foreach
                }
            }//lazyvstack
            .padding(.top, 8)
            .padding(.bottom, 100)
            
        }//scrollview
    }
}

//#Preview {
//    UserFollowView(viewModel: ProfileViewModel())
//}
