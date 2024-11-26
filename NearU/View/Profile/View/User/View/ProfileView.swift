//
//  ProfileView.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/04/30.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State var isShowWordCloud: Bool = false

    let date: Date
    let isShowFollowButton: Bool
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98)

    init(user: User, currentUser: User, date: Date, isShowFollowButton: Bool = false) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user, currentUser: currentUser))

        self.date = date
        self.isShowFollowButton = isShowFollowButton
    }

    var body: some View {
        ZStack{
            backgroundColor.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    //MARK: - HEADER
                    ProfileHeaderView(viewModel: viewModel, date: date, isShowFollowButton: isShowFollowButton)

                    //MARK: - SNSLINKS
                    HStack {
                        Text("SNS")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                            .padding(.leading, 10)

                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, 10)
                    }

                    if viewModel.user.isPrivate && !viewModel.isMutualFollow {
                        Text("非公開アカウントです")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if viewModel.user.snsLinks.isEmpty {
                                Text("リンクがありません")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach (Array(viewModel.user.snsLinks.keys), id: \.self) { key in
                                    if let url = viewModel.user.snsLinks[key] {
                                        SNSLinkButtonView(selectedSNS: key, sns_url: url, isShowDeleteButton: false)
                                            .disabled(viewModel.user.isPrivate && !viewModel.isMutualFollow)
                                    }
                                }
                            }
                        }//hstack
                        .padding(.vertical, 5)
                    }//scrollview
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                    //MARK: - ARTICLES
                    HStack {
                        Text("記事")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                            .padding(.leading, 10)

                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, 10)
                    }
                    .padding(.bottom, 10)

                    VStack(spacing: 20) {
                        if viewModel.openGraphData.isEmpty {
                            Text("記事がありません")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.openGraphData) { openGraphData in
                                SiteLinkButtonView(ogpData: openGraphData, showDeleteButton: false)
                            }
                        }
                    }//Vstack
                    .padding(.bottom, 100)
                } //vstack
            }//scrollView
            .refreshable {
                await viewModel.loadUserData()
            }

        } //zstack
        .ignoresSafeArea()

    }//body
}//view

#Preview {
    ProfileView(user: User.MOCK_USERS[0], currentUser: User.MOCK_USERS[1], date: Date())
}
