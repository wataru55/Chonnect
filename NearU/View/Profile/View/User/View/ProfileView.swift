//
//  ProfileView.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/04/30.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss

    let date: Date
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98)

    init(user: User, currentUser: User, date: Date) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user, currentUser: currentUser))

        self.date = date
    }

    var body: some View {
        ZStack{
            backgroundColor.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    //MARK: - HEADER
                    ProfileHeaderView(viewModel: viewModel, date: date)

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

                    if !viewModel.user.isPrivate || viewModel.currentUser.connectList.contains(viewModel.user.id) && viewModel.user.connectList.contains(viewModel.currentUser.id){

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack() {
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
                                        }
                                    }
                                }
                            }//hstack
                        }//scrollview
                        .padding(.leading, 5)
                        .padding(.bottom)

                    } else {
                        Spacer()
                        Text("相互フォローではないためSNSリンクは表示されません")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding()

                        Spacer()
                    }

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
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.black)
                }
            }
        }
    }//body
}//view

#Preview {
    ProfileView(user: User.MOCK_USERS[0], currentUser: User.MOCK_USERS[1], date: Date())
}