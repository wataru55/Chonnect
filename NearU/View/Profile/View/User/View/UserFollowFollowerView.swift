//
//  UserFollowFollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/14.
//

import SwiftUI

struct UserFollowFollowerView: View {
    let follows: [User]
    let followers: [User]
    let userName: String
    @State var selectedTab: Int

    var body: some View {
        VStack {
            HStack {
                CustomTabBarButtonView(selected: $selectedTab, title: "フォロー", tag: 0)
                CustomTabBarButtonView(selected: $selectedTab, title: "フォロワー", tag: 1)
            }
            .padding()
            
            TabView(selection: $selectedTab) {
                UserFollowView(follows: follows)
                    .tag(0)
                
                UserFollowerView(followers: followers)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // インジケータを非表示
        }
        .ignoresSafeArea(edges:.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(userName)")
        .navigationBack()
    }
}

//#Preview {
//    UserFollowFollowerView(selectedTab: 0)
//}
