//
//  ConnectedSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.
//

import SwiftUI

struct ConnectedSearchView: View {
    //MARK: - property
    let currentUser: User
    @StateObject var viewModel: ConnectedSearchViewModel

    init(currentUser: User) {
        self.currentUser = currentUser
        self._viewModel = StateObject(wrappedValue: ConnectedSearchViewModel(currentUser: currentUser))
    }


    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack (spacing: 16){
                    ForEach(viewModel.ConnectedUsers) { user in
                        NavigationLink(value: user) {
                            HStack {
                                CircleImageView(user: user, size: .xsmall)
                                VStack (alignment: .leading){
                                    Text(user.username)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.primary)

                                    if let fullname = user.fullname { //fullnameがnilじゃないなら
                                        Text(fullname)
                                            .foregroundStyle(Color.primary)
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

            }//scrollview
            .navigationDestination(for: User.self, destination: { value in
                ProfileView(user: value, currentUser: currentUser)
            })
        }//navigationstack
    }
}

#Preview {
    ConnectedSearchView(currentUser: User.MOCK_USERS[0])
}
