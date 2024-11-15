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
                    UserFollowView(viewModel: viewModel)
                } else {
                    UserFollowerView(viewModel: viewModel)
                }
            }
            .navigationDestination(for: UserHistoryRecord.self, destination: { follower in
                ProfileView(user: follower.user, currentUser: viewModel.currentUser, date: follower.date)
            })
            .navigationDestination(for: UserDatePair.self, destination: { pair in
                ProfileView(user: pair.user, currentUser: viewModel.currentUser, date: pair.date)
            })
            .ignoresSafeArea(edges:.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(viewModel.user.username)")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
}

//#Preview {
//    UserFollowFollowerView(selectedTab: 0)
//}
