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
    @StateObject var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack (spacing: 16){
                    ForEach(viewModel.users) { user in
                        NavigationLink(value: user) {
                            HStack {
                                CircleImageView(user: user, size: .xsmall)
                                VStack (alignment: .leading){
                                    Text(user.username)
                                        .fontWeight(.bold)

                                    if let fullname = user.fullname { //usernameがnilじゃないなら
                                        Text(fullname)
                                    }

                                }//vstack
                                .font(.footnote)

                                Spacer()
                            }//hstack
                            .foregroundStyle(.black) //navigationlinkのデフォルトカラーを青から黒に
                            .padding(.horizontal)
                        }//navigationlink
                    }//foreach
                }//lazyvstack
                .padding(.top, 8)
                .searchable(text: $searchText, prompt: "Search...") //検索欄
            }//scrollview
            .navigationDestination(for: User.self, destination: { value in
                ProfileView(user: value, currentUser: currentUser)
            })
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
        }//navigationstack
    }
}

#Preview {
    SearchView(currentUser: User.MOCK_USERS[0])
}
