//
//  UserFollowFollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/14.
//

import SwiftUI

struct UserFollowFollowerView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var searchText: String = ""
    @State var selectedTab: Int

    var body: some View {
        //NavigationStack {
            VStack {
                EmptyView()
                    .searchable(text: $searchText, prompt: "Search...")

                HStack {
                    CustomTabBarButtonView(selected: $selectedTab, title: "フォロー", tag: 0)
                    CustomTabBarButtonView(selected: $selectedTab, title: "フォロワー", tag: 1)
                }
                .padding()

                TabView(selection: $selectedTab) {
                    UserFollowView(viewModel: viewModel)
                        .tag(0)
                    
                    UserFollowerView(viewModel: viewModel)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // インジケータを非表示
            }
            .ignoresSafeArea(edges:.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(viewModel.user.username)")
        //}
    }
}

//#Preview {
//    UserFollowFollowerView(selectedTab: 0)
//}
