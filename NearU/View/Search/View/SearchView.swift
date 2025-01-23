//
//  SearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/18.
//
import SwiftUI

struct SearchView: View {
    @StateObject var historyManager = RealmHistoryManager()
    let currentUser: User
    @State private var searchText: String = ""
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 上部にChonnectの画像
                Image("Chonnect")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 20)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                // 検索バー
                TextField("Search...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // コンテンツ
                VStack {
                    TopTabView(currentUser: currentUser)
                }
                .padding(.top, 10)
            }
            .navigationBarHidden(true) // デフォルトのナビゲーションバーを非表示
        }
        .tint(.black)
    }
}

#Preview {
    SearchView(currentUser: User.MOCK_USERS[0])
}
