//
//  ConnectedSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.
//

import SwiftUI

struct FollowView: View {
    @EnvironmentObject var viewModel: FollowViewModel

    var currentUser: User

    var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    if viewModel.userDatePairs.isEmpty {
                        Text("フォローしているユーザーがいません")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.userDatePairs, id: \.self) { pair in
                            NavigationLink(value: pair) {
                                HStack {
                                    CircleImageView(user: pair.user, size: .xsmall, borderColor: .clear)
                                    VStack (alignment: .leading){
                                        Text(pair.user.username)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.primary)

                                        if let fullname = pair.user.fullname { //fullnameがnilじゃないなら
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
                    }
                }//lazyvstack
                .padding(.top, 8)

            }//scrollview
            .refreshable {
                print("refresh")
            }
    }
}

#Preview {
    FollowView(currentUser: User.MOCK_USERS[0])
        .environmentObject(FollowViewModel())
}
