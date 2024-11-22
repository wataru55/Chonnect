//
//  FollowFollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import SwiftUI

struct FollowFollowerView: View {
    @EnvironmentObject var followViewModel: FollowViewModel
    @EnvironmentObject var followerViewModel: FollowerViewModel
    @State private var searchText: String = ""
    @State var selectedTab: Int
    @Environment(\.dismiss) var dismiss

    let currentUser: User

    var body: some View {
        VStack {
            EmptyView()
                .searchable(text: $searchText, prompt: "Search...")

            HStack {
                CustomTabBarButtonView(selected: $selectedTab, title: "フォロー", tag: 0)
                CustomTabBarButtonView(selected: $selectedTab, title: "フォロワー", tag: 1)
            }
            .padding()

            if selectedTab == 0 {
                FollowView(currentUser: currentUser).tag(0)
                    .environmentObject(followViewModel)
            } else {
                FollowerView(currentUser: currentUser).tag(1)
                    .environmentObject(followerViewModel)
            }
        }
        .ignoresSafeArea(edges:.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(currentUser.username)")
    }
}

#Preview {
    FollowFollowerView(selectedTab: 0, currentUser: User.MOCK_USERS[0])
}
