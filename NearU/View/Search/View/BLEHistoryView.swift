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
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.sortedHistoryRowData.isEmpty {
                    Text("すれちがったユーザーはいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.sortedHistoryRowData, id: \.self) { data in
                        NavigationLink {
                            ProfileView(user: data.record.user, currentUser: currentUser, date: data.record.date,
                                        isShowFollowButton: true, isShowDateButton: true)
                                .onAppear {
                                    viewModel.markAsRead(data.record)
                                }
                        } label: {
                            UserRowView(user: data.record.user, tags: data.tags,
                                        date: data.record.date, isRead: data.record.isRead,
                                        rssi: nil, isFollower: data.isFollowed)
                        }
                    } // ForEach
                }
            } // LazyVStack
            .padding(.top, 8)
            .padding(.bottom, 100)

        } // ScrollView
        .refreshable {
            loadingViewModel.isLoading = true
            Task {
                // データのフェッチ
                await UserService.fetchNotifications()
                RealmManager.shared.loadHistoryDataFromRealm()
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
