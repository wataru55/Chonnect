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

    // 日付をフォーマットするためのフォーマッター
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

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
                        historyRow(for: pair)
                    } // ForEach
                }
            } // LazyVStack
            .padding(.top, 8)
            .navigationDestination(for: UserHistoryRecord.self, destination: { pair in
                ProfileView(user: pair.user, currentUser: currentUser, date: pair.date)
                    .onAppear {
                        viewModel.markAsRead(pair)
                    }
            })
        } // ScrollView
        .refreshable {
            loadingViewModel.isLoading = true
            Task {
                // データのフェッチ
                await UserService().fetchNotifications()
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

    // 切り出した行表示メソッド
    @ViewBuilder
    private func historyRow(for pair: UserHistoryRecord) -> some View {
        NavigationLink(value: pair) {
            HStack {
                CircleImageView(user: pair.user, size: .xsmall, borderColor: .clear)
                VStack(alignment: .leading) {
                    HStack {
                        Text(pair.user.username)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primary)

                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(pair.isRead ? .clear : .blue)
                    }

                    if let fullname = pair.user.fullname {
                        Text(fullname)
                            .foregroundStyle(Color.primary)
                    }
                } // VStack
                .font(.footnote)

                Spacer()

                Text("\(dateFormatter.string(from: pair.date))")
                    .font(.caption)
                    .foregroundColor(.gray)

                Button(action: {
                    Task {
                        loadingViewModel.isLoading = true
                        do {
                            try await viewModel.handleFollowButton(currentUser: currentUser, pair: pair)
                            loadingViewModel.isLoading = false
                        } catch {
                            isShowAlert = true
                        }
                    }
                }, label: {
                    Image(systemName: "figure.2")
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 35)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(6)
                    })

                Button(action: {
                    RealmManager.shared.removeData(pair.user.id)
                }, label: {
                    Image(systemName: "hand.wave.fill")
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 35)
                        .background(.gray)
                        .cornerRadius(6)
                })
            } // HStack
            .foregroundStyle(.black) // NavigationLinkのデフォルトカラーを青から黒に
            .padding(.horizontal)
        } // NavigationLink
    }

}

#Preview {
    BLEHistoryView(currentUser: User.MOCK_USERS[0])
}
