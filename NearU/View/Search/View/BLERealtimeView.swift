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
                        realtimeRow(for: pair)
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
    // 日付をフォーマットするためのフォーマッター
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    // 切り出した行表示メソッド
    @ViewBuilder
    private func realtimeRow(for pair: UserRealtimeRecord) -> some View {
        NavigationLink(value: pair) {
            HStack {
                CircleImageView(user: pair.user, size: .xsmall, borderColor: .clear)
                VStack(alignment: .leading) {
                    Text(pair.user.username)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)

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
            } // HStack
            .foregroundStyle(.black) // NavigationLinkのデフォルトカラーを青から黒に
            .padding(.horizontal)
        } // NavigationLink
    }
}

#Preview {
    BLERealtimeView(currentUser: User.MOCK_USERS[0])
}
