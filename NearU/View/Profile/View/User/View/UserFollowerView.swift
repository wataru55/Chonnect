//
//  UserFollowerView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/14.
//

import SwiftUI

struct UserFollowerView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.followers.isEmpty {
                    Text("フォローされているユーザーがいません")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.followers, id: \.self) { follower in
                        NavigationLink(value: follower) {
                            HStack {
                                CircleImageView(user: follower.user, size: .xsmall, borderColor: .clear)
                                VStack (alignment: .leading){
                                    Text(follower.user.username)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.primary)

                                    if let fullname = follower.user.fullname { //fullnameがnilじゃないなら
                                        Text(fullname)
                                            .foregroundStyle(Color.primary)
                                    }

                                }//vstack
                                .font(.footnote)

                                Spacer()
                            }//hstack
                            .foregroundStyle(.black) //navigationlinkのデフォルトカラーを青から黒に
                            .padding(.horizontal)
                        } //navigationlink
                    } //foreach
                }
            } //lazyvstack
            .padding(.top, 8)

        } //scrollview
        .refreshable {
            print("refresh")
        }
    }
}

//#Preview {
//    UserFollowerView()
//}
