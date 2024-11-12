//
//  SearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/18.
//
import SwiftUI

struct SearchView: View {
    //MARK: - property
    let currentUser: User
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack (spacing: -10){
                EmptyView()
                    .searchable(text: $searchText, prompt: "Search...") //検索欄

                VStack {
                    TopTabView(currentUser: currentUser)

                }//vstack
                .navigationTitle("発見")
                .navigationBarTitleDisplayMode(.inline)
            }
        }

    }
}

#Preview {
    SearchView(currentUser: User.MOCK_USERS[0])
}
