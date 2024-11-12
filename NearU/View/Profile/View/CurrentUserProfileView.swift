//
//  CurrentUserProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/21.
//

import SwiftUI
import Kingfisher

struct CurrentUserProfileView: View {
    @StateObject private var viewModel = CurrentUserProfileViewModel()
    @StateObject var articleLinksViewModel = ArticleLinksViewModel()
    @StateObject var addLinkViewModel = AddLinkViewModel()
    @State private var isAddingNewLink = false
    @State private var showEditAbstract = false
    @State private var showEditProfile = false

    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98)

    let grayColor = Color.init(white: 0.8, opacity: 1)

    let user: User

    var body: some View {
        ZStack{
            backgroundColor.ignoresSafeArea()

            VStack{
                ScrollView(.vertical, showsIndicators: false){
                    //MARK: - HEADER
                    VStack{
                        BackgroundImageView(user: user, height: 500, isGradient: true)
                            .overlay(alignment: .bottomLeading) {
                                VStack(alignment: .leading){
                                    TagsView(tags: viewModel.selectedLanguageTags)

                                    TagsView(tags: viewModel.selectedFrameworkTags)

                                    Text(user.username)
                                        .font(.system(size: 25, weight: .bold, design: .default))
                                        .padding(.bottom, 1)
                                        .padding(.top, 5)

                                    if let fullname = user.fullname{
                                        Text(fullname)
                                            .font(.system(size: 13, weight: .regular, design: .default))
                                            .padding(.bottom, 5)
                                    }

                                    if let bio = user.bio {
                                        Text(bio)
                                            .font(.callout)
                                            .frame(alignment: .leading)
                                    }
                                }//VStack
                                .padding(.bottom)
                                .padding(.leading)
                            }
                            .overlay(alignment: .topTrailing){
                                Button {
                                    showEditProfile.toggle()
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(
                                            Color.black.opacity(0.6)
                                                .clipShape(Circle())
                                        )
                                }
                                .padding(.top, 50)
                                .padding(.trailing, 20)
                            }
                    }//vstack
                    .padding(.bottom, 10)

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

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if user.snsLinks.isEmpty {
                                Button {
                                    isAddingNewLink.toggle()
                                } label: {
                                    HStack(spacing: 0) {
                                        Image(systemName: "plus.circle")
                                            .font(.title2)
                                        Text("自分のSNSのリンクを登録しましょう")
                                            .padding()
                                    }
                                    .foregroundColor(.mint)
                                }
                                .padding(.leading, 8)

                            } else {
                                ForEach(Array(addLinkViewModel.snsUrls.keys), id: \.self) { key in
                                    if let url = addLinkViewModel.snsUrls[key] {
                                        SNSLinkButtonView(selectedSNS: key, sns_url: url, isShowDeleteButton: false)
                                    }
                                }

                                Button(action: {
                                    isAddingNewLink.toggle()
                                }, label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                                        .frame(width: 80, height: 80)
                                        .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color(red: 0.45, green: 0.45, blue: 0.45), lineWidth: 1)
                                        )
                                })
                                .padding(.horizontal, 8)
                            }
                        } // HStack
                        .padding(.vertical, 5)
                    } // ScrollView
                    .padding(.leading)
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

                    VStack(alignment: .trailing, spacing: 20) {
                        if articleLinksViewModel.openGraphData.isEmpty {
                            Button {
                                showEditAbstract.toggle()
                            } label: {
                                HStack(spacing: 0) {
                                    Image(systemName: "plus.circle")
                                        .font(.title2)
                                    Text("記事のリンクを登録しましょう")
                                        .padding()
                                }
                                .foregroundColor(.mint)
                            }
                            .padding(.leading, 8)

                        } else {
                            ForEach(articleLinksViewModel.openGraphData) { openGraphData in
                                SiteLinkButtonView(ogpData: openGraphData, showDeleteButton: false)
                                    .environmentObject(articleLinksViewModel)
                            }

                            Button {
                                showEditAbstract.toggle()
                            } label: {
                                Text("edit abstract")
                                    .font(.footnote)
                                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                                    .padding(10)
                                    .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(red: 0.45, green: 0.45, blue: 0.45), lineWidth: 1)
                                        )
                            }
                            .frame(height: 100, alignment: .top)
                        }
                    }
                }//scrollview
                .fullScreenCover(isPresented: $showEditProfile) {
                    EditProfileView(user: viewModel.user)
                        .environmentObject(viewModel)
                }
                .fullScreenCover(isPresented: $isAddingNewLink) {
                    AddLinkView()
                        .environmentObject(addLinkViewModel)
                }
                .fullScreenCover(isPresented: $showEditAbstract) {
                    EditAbstractView()
                        .environmentObject(articleLinksViewModel)
                }
            }//vstack
        }// zstack
        .ignoresSafeArea()
    }// body
}// view
