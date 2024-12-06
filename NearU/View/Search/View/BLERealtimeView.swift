//
//  BLERealtimeView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/06.
//

import SwiftUI

struct BLERealtimeView: View {
    @StateObject var viewModel = BLERealtimeViewModel()
    @EnvironmentObject var loadingViewModel: LoadingViewModel
    @State var isShowAlert: Bool = false

    let currentUser: User

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // TODO: 毎回一瞬だけ表示されるから関数で渡すべきかも
                if viewModel.sortedUserRealtimeRecords.isEmpty {
                    Text("付近にユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.sortedUserRealtimeRecords, id: \.self) { data in
                        NavigationLink {
                            ProfileView(user: data.user, currentUser: currentUser, date: data.date,
                                        isShowFollowButton: true, isShowDateButton: true)
                        } label: {
                            UserRowView(user: data.user, tags: data.tags, date: nil,
                                        isRead: false, rssi: data.rssi, isFollower: false)
                        }
                    } // ForEach
                }
            } // LazyVStack
            .padding(.top, 8)
            .padding(.bottom, 100)

        } // ScrollView
        .alert("エラー", isPresented: $isShowAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("予期せぬエラーが発生しました\nもう一度お試しください")
        }
    }
}

#Preview {
    BLERealtimeView(currentUser: User.MOCK_USERS[0])
}
