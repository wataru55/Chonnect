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
    @StateObject var addLinkViewModel = EditSNSLinkViewModel()
    @StateObject var followViewModel = FollowViewModel()
    @StateObject var followerViewModel = FollowerViewModel()
    @StateObject var tagsViewModel = EditSkillTagsViewModel()

    @State private var isAddingNewLink = false
    @State private var showEditArticle = false
    @State private var showEditProfile = false
    @State private var showEditTags = false

    @State private var isShowWordCloud = false

    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98)

    let user: User

    var body: some View {
        NavigationStack {
            ZStack{
                backgroundColor.ignoresSafeArea()

                VStack{
                    ScrollView(.vertical, showsIndicators: false){
                        //MARK: - HEADER
                        VStack{
                            BackgroundImageView(user: user, height: 500, isGradient: true)
                                .overlay(alignment: .bottomLeading) {
                                    VStack(alignment: .leading){
                                        Top3TabView(tags: tagsViewModel.skillSortedTags)
                                            .onTapGesture {
                                                withAnimation {
                                                    isShowWordCloud.toggle()
                                                }
                                            }

                                        HStack(spacing: 4) {
                                            Text(user.username)
                                                .font(.system(size: 35, weight: .bold, design: .default))
                                                .padding(.bottom, 1)
                                                .padding(.top, 5)

                                            Image(systemName: user.isPrivate ? "lock.fill" : "lock.open.fill")
                                                .font(.subheadline)
                                                .offset(y: 7)
                                        }

                                        HStack {
                                            NavigationLink(value: FollowNavigationData(selectedTab: 0, currentUser: user)) {
                                                CountView(count: followViewModel.followUsers.count, text: "フォロー")
                                            }

                                            NavigationLink(value: FollowNavigationData(selectedTab: 1, currentUser: user)) {
                                                CountView(count: followerViewModel.followers.count, text: "フォロワー")
                                            }
                                        }
                                        .padding(.bottom, 5)

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
                                    VStack {
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

                                        Button {
                                            showEditTags.toggle()
                                        } label: {
                                            Image(systemName: "tag")
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

                        VStack(alignment: .center, spacing: 10) {
                            if articleLinksViewModel.openGraphData.isEmpty {
                                Button {
                                    showEditArticle.toggle()
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

                                Button(action: {
                                    showEditArticle.toggle()
                                }, label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                                        .frame(width: 30, height: 30)
                                        .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color(red: 0.45, green: 0.45, blue: 0.45), lineWidth: 1)
                                        )
                                })
                                .frame(height: 130, alignment: .top)
                            }
                        }
                    }//scrollview
                    .fullScreenCover(isPresented: $showEditProfile) {
                        EditProfileView(user: viewModel.user)
                            .environmentObject(viewModel)
                    }
                    .fullScreenCover(isPresented: $isAddingNewLink) {
                        EditSNSLinkView()
                            .environmentObject(addLinkViewModel)
                    }
                    .fullScreenCover(isPresented: $showEditArticle) {
                        EditArticleView()
                            .environmentObject(articleLinksViewModel)
                    }
                    .fullScreenCover(isPresented: $showEditTags) {
                        EditSkillTagsView(viewModel: tagsViewModel)
                    }

                }//vstack

                if isShowWordCloud {
                    TagIndexView(viewModel: tagsViewModel)
                        .background(Color.white.opacity(0.7))
                        .ignoresSafeArea()
                        .onTapGesture {
                            isShowWordCloud.toggle()
                        }
                }
            }// zstack
            .ignoresSafeArea()
            .navigationDestination(for: FollowNavigationData.self) { data in
                FollowFollowerView(selectedTab: data.selectedTab, currentUser: data.currentUser)
                    .environmentObject(followViewModel)
                    .environmentObject(followerViewModel)
            }
        }
        .tint(.black)
    }// body
}// view

struct FollowNavigationData: Hashable {
    let selectedTab: Int
    let currentUser: User
}
