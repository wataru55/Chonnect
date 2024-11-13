//
//  FollowFollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import SwiftUI

struct FollowFollowerView: View {
    @EnvironmentObject var followViewModel: FollowViewModel
    @State private var searchText: String = ""
    @State var selectedTab: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                EmptyView()
                    .searchable(text: $searchText, prompt: "Search...")

                HStack {
                    CustomTabBarButtonView(selected: $selectedTab, title: "フォロー", tag: 0)
                    CustomTabBarButtonView(selected: $selectedTab, title: "フォロワー", tag: 1)
                }
                .padding()

                if selectedTab == 0 {
                    FollowView().tag(0)
                        .environmentObject(followViewModel)
                } else {
                    FollowerView().tag(1)
                }
            }
            .ignoresSafeArea(edges:.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("ユーザー名")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.backward")
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        }
    }
}

#Preview {
    FollowFollowerView(selectedTab: 0)
}
