//
//  ConnectedSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.
//

import SwiftUI

struct FollowView: View {
    @EnvironmentObject var viewModel: FollowViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.follows.isEmpty {
                    NothingDataView(
                        text: "フォローしているユーザーがいません",
                        explanation: "ここでは、あなたがフォローしたユーザーの一覧が表示されます。",
                        isSystemImage: true,
                        isAbleToReload: true)

                } else {
                    ForEach(viewModel.follows, id: \.self) { followUser in
                        NavigationLink(value: followUser) {
                            UserRowView(
                                user: followUser.user, tags: followUser.user.interestTags,
                                date: followUser.date, rssi: nil)
                        }
                    }  //foreach
                }
            }  //lazyvstack
            .padding(.top, 8)
            .padding(.bottom, 100)

        }  //scrollview
        .refreshable {
            Task {
                await viewModel.reload()
            }
        }
    }
}

// #Preview {
//     FollowView()
//         .environmentObject(FollowViewModel())
// }
