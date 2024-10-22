//
//  ProfileView.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/04/30.
//

import SwiftUI

struct ProfileView: View {
    //MARK: - property
    @StateObject var viewModel: ProfileViewModel

    let date: Date

    init(user: User, currentUser: User, date: Date) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user, currentUser: currentUser))
        self.date = date
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                //header
                ProfileHeaderView(viewModel: viewModel, date: date)

                Divider()
                //link scroll view

                if !viewModel.user.isPrivate || viewModel.currentUser.connectList.contains(viewModel.user.id) && viewModel.user.connectList.contains(viewModel.currentUser.id){
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach (Array(viewModel.user.snsLinks.keys), id: \.self) { key in
                                if let url = viewModel.user.snsLinks[key] {
                                    SNSLinkButtonView(selectedSNS: key, sns_url: url)
                                }
                            }
                        }//hstack
                    }//scrollview
                    .padding(.leading, 5)

                } else {
                    Spacer()
                    Text("このユーザは非公開です")
                    Spacer()
                }
            }//Vstack
        }//scrollView
        .navigationTitle(viewModel.user.username)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.loadUserData()
        }
        .onAppear {
            Task {
                await viewModel.loadUserData()
            }
        }
    }//body
}//view

#Preview {
    ProfileView(user: User.MOCK_USERS[0], currentUser: User.MOCK_USERS[1], date: Date())
}
