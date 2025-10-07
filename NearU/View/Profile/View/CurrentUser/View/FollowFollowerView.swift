//
//  FollowFollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import SwiftUI

struct FollowFollowerView: View {
    @StateObject var followViewModel: FollowViewModel
    @StateObject var followerViewModel: FollowerViewModel
    @State var selectedTab: Int
    @Environment(\.dismiss) var dismiss

    init(selectedTab: Int, followData: [HistoryDataStruct], followerData: [HistoryDataStruct]) {
        self.selectedTab = selectedTab
        _followViewModel = StateObject(
            wrappedValue: FollowViewModel(followData: followData)
        )
        _followerViewModel = StateObject(
            wrappedValue: FollowerViewModel(followerData: followerData)
        )
    }

    var body: some View {
        VStack {
            HStack {
                CustomTabBarButtonView(selected: $selectedTab, title: "フォロー", tag: 0)
                CustomTabBarButtonView(selected: $selectedTab, title: "フォロワー", tag: 1)
            }
            .padding()

            TabView(selection: $selectedTab) {
                FollowView()
                    .environmentObject(followViewModel)
                    .tag(0)

                FollowerView()
                    .environmentObject(followerViewModel)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))  // インジケータを非表示
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(AuthService.shared.currentUser?.username ?? "")")
        .navigationBack()
    }
}

// #Preview {
//     FollowFollowerView(selectedTab: 0)
// }
