//
//  AllSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.

import SwiftUI

struct BLEHistoryView: View {
    // MARK: - property
    @StateObject var viewModel = BLEHistoryViewModel()
    @EnvironmentObject var loadingViewModel: LoadingViewModel
    @State var isShowAlert: Bool = false

    let currentUser: User

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.sortedUserHistoryRecords.isEmpty {
                    Text("すれちがったユーザーはいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.sortedUserHistoryRecords, id: \.self) { pair in
                        // TODO: isFollowerを動的に設定
                        UserRowView(value: pair, user: pair.user, date: pair.date, isRead: pair.isRead, rssi: nil, isFollower: false)
                    } // ForEach
                }
            } // LazyVStack
            .padding(.top, 8)
            .navigationDestination(for: UserHistoryRecord.self, destination: { pair in
                ProfileView(user: pair.user, currentUser: currentUser, date: pair.date, isShowFollowButton: true)
                    .onAppear {
                        viewModel.markAsRead(pair)
                    }
            })
        } // ScrollView
        .refreshable {
            loadingViewModel.isLoading = true
            Task {
                // データのフェッチ
                await UserService.fetchNotifications()
                // ローディング終了
                //isLoading = false
                loadingViewModel.isLoading = false
            }
        }
        .alert("エラー", isPresented: $isShowAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("予期せぬエラーが発生しました\nもう一度お試しください")
        }
    }
}

#Preview {
    BLEHistoryView(currentUser: User.MOCK_USERS[0])
}
