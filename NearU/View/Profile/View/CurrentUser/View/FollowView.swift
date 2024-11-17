//
//  ConnectedSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.
//

import SwiftUI

struct FollowView: View {
    @EnvironmentObject var viewModel: FollowViewModel

    var currentUser: User

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.userDatePairs.isEmpty {
                    Text("フォローしているユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.userDatePairs, id: \.self) { pair in
                        //TODO: isFollowerを動的に設定
                        UserRowView(value: pair, user: pair.user, date: pair.date, isRead: nil, rssi: nil, isFollower: true)
                    }//foreach
                }
            }//lazyvstack
            .padding(.top, 8)
            .navigationDestination(for: UserDatePair.self, destination: { pair in
                ProfileView(user: pair.user, currentUser: currentUser, date: pair.date, isShowFollowButton: true)
            })
            
        }//scrollview
        .refreshable {
            print("refresh")
        }
    }
}

#Preview {
    FollowView(currentUser: User.MOCK_USERS[0])
        .environmentObject(FollowViewModel())
}
