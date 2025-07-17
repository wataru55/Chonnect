//
//  BlockListView.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/26.
//

import SwiftUI

struct BlockListView: View {
    @StateObject private var viewModel = BlockListViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.blockList.isEmpty {
                    NothingDataView(text: "ブロックしたユーザーがいません",
                                    explanation: "ここでは、あなたがブロックしたユーザーの一覧が表示されます。",
                                    isSystemImage: true,
                                    isAbleToReload: false)
                    
                } else {
                    ForEach(viewModel.blockList, id: \.self) { user in
                        blockUserRow(user: user)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
            .navigationTitle("ブロックリスト")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBack()
        .onAppear {
            Task {
                await viewModel.loadBlockList()
            }
        }
    }
    
    private func blockUserRow(user: User) -> some View {
        HStack {
            CircleImageView(user: user, size: .small, borderColor: .clear)
                .padding(.trailing, 5)
            
            Text(user.username)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.unblockUser(user: user)
                }
            } label: {
                Text("解除")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.pink)
                            .shadow(color: .gray.opacity(0.5), radius: 1, x: 1, y: 1)
                    )
            }
        }
        .padding(.horizontal)
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .padding(.horizontal, 5)
                .foregroundStyle(.white)
                .shadow(color: .gray.opacity(0.5), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    BlockListView()
}
