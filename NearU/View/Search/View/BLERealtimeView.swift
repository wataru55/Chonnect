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
        ScrollView {
            LazyVStack(spacing: 16) {
                // TODO: 毎回一瞬だけ表示されるから関数で渡すべきかも
                if viewModel.sortedUserRealtimeRecords.isEmpty {
                    Text("付近にユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.sortedUserRealtimeRecords, id: \.self) { pair in
                        UserRowView(value: pair, user: pair.user, date: nil, isRead: nil, rssi: pair.rssi, isFollower: false)
                    } // ForEach
                }
            } // LazyVStack
            .padding(.top, 8)
            .navigationDestination(for: UserRealtimeRecord.self, destination: { pair in
                ProfileView(user: pair.user, currentUser: currentUser, date: pair.date)
            })
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
