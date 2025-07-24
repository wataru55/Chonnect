//
//  AllSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.

import SwiftUI

struct BLEHistoryView: View {
    // MARK: - property
    @ObservedObject var viewModel: BLEHistoryViewModel
    @EnvironmentObject var loadingViewModel: LoadingViewModel
    @State var isShowAlert: Bool = false

    let currentUser: User

    var body: some View {
        VStack {
            if viewModel.isShowMarker {
                Text("更新データがあります")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.mint)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.sortedHistoryRowData.isEmpty {
                        NothingDataView(text: "すれちがったユーザーがいません",
                                        explanation: "ここでは、過去にすれちがったユーザーの一覧が表示されます。",
                                        isSystemImage: false,
                                        isAbleToReload: true)
                    } else {
                        ForEach(viewModel.sortedHistoryRowData, id: \.self) { data in
                            NavigationLink(value: data) { // userオブジェクトそのものを値として渡す
                                UserRowView(user: data.user, tags: data.user.interestTags,
                                            date: data.date, rssi: nil)
                            }
                                                    
                        } // ForEach
                    }
                } // LazyVStack
                .padding(.top, 8)
                .padding(.bottom, 100)

            } // ScrollView
            .refreshable {
                Task {
                    await viewModel.makeHistoryRowData()
                }
            }
        }
        .onFirstAppear {
            Task {
                await viewModel.makeHistoryRowData()
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
    BLEHistoryView(viewModel: BLEHistoryViewModel(), currentUser: User.MOCK_USERS[0])
}
