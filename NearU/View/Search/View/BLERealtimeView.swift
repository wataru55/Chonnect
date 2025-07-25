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
                    NothingDataView(text: "付近にユーザーがいません",
                                    explanation: "ここでは、近くにいるユーザーの一覧を表示します。",
                                    isSystemImage: false,
                                    isAbleToReload: false)

                } else {
                    ForEach(viewModel.sortedUserRealtimeRecords, id: \.self) { data in
                        NavigationLink(value: data.pairData) {
                            UserRowView(user: data.pairData.user, tags: data.pairData.user.interestTags, date: nil,
                                        rssi: data.rssi)
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
