//
//  UserFollowView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/14.
//

import SwiftUI
import Combine

struct UserFollowView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.follows.isEmpty {
                    Text("フォローしているユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.follows, id: \.self) { followUser in
                        NavigationLink(value: followUser) {
                            HStack {
                                CircleImageView(user: followUser.user, size: .xsmall, borderColor: .clear)
                                VStack (alignment: .leading){
                                    Text(followUser.user.username)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.primary)

                                    if let fullname = followUser.user.fullname { //fullnameがnilじゃないなら
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

//#Preview {
//    UserFollowView(viewModel: ProfileViewModel())
//}
