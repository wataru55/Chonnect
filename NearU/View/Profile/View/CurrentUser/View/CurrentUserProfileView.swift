//
//  CurrentUserProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/21.
//

import SwiftUI
import Kingfisher

enum CurrentUserProfileDestination: Hashable {
    case editProfile
    case editSkillTags
    case editSNSLink
    case editArticle
    case wordCloud
    case followFollower(FollowNavigationData)
    
    // EditProfileView 内でさらに分岐する遷移
    case profileImage
    case userName
    case bio
    case attribute
    case interestTags
}

struct CurrentUserProfileView: View {
    @StateObject private var viewModel = CurrentUserProfileViewModel()
    @StateObject var articleLinksViewModel = ArticleLinksViewModel()
    @StateObject var addLinkViewModel = EditSNSLinkViewModel()
    @StateObject var followViewModel = FollowViewModel()
    @StateObject var followerViewModel = FollowerViewModel()
    @StateObject var tagsViewModel = EditSkillTagsViewModel()
    
    @State var path = NavigationPath()
    @State private var isBioExpanded: Bool = false
    
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98)
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack{
                backgroundColor.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false){
                    ZStack(alignment: .top) {
                        BackgroundImageView(user: viewModel.user, height: 500, isGradient: true)
                        
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: 50)
                            
                            overlayButtonActions()
                            
                            Spacer()
                                .frame(height: 200)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Attributes(attributes: viewModel.user.attributes, availableOpacity: true)
                                
                                userNameAndPrivateIcon()
                                
                                followFollowerCountView()
                                
                                bio()
                                
                                interestTags()
                                
                                skillTags()
                            } //VStack
                        } // VStack
                        .padding(.leading, 10)
                    } // ZStack
                    .padding(.bottom, 10)
                    
                    sectionHeader(title: "SNS")
                    
                    snsLinks()
                    
                    sectionHeader(title: "記事")
                    
                    articleLinks()
                    
                }//scrollview
            }// zstack
            .ignoresSafeArea()
            .navigationDestination(for: CurrentUserProfileDestination.self) { destination in
                switch destination {
                case .editProfile:
                    EditProfileView()
                        .environmentObject(viewModel)
                case .editSkillTags:
                    EditSkillTagsView(viewModel: tagsViewModel)
                case .editSNSLink:
                    EditSNSLinkView()
                        .environmentObject(addLinkViewModel)
                case .editArticle:
                    EditArticleView()
                        .environmentObject(articleLinksViewModel)
                case .wordCloud:
                    WordCloudView(skillSortedTags: tagsViewModel.skillSortedTags)
                    
                case .followFollower(let data):
                    FollowFollowerView(selectedTab: data.selectedTab,
                                       currentUser: data.currentUser)
                    .environmentObject(followViewModel)
                    .environmentObject(followerViewModel)
                    
                case .profileImage:
                    EditImageView()
                case .userName:
                    EditUserNameView()
                        .environmentObject(viewModel)
                case .bio:
                    EditBioView()
                        .environmentObject(viewModel)
                case .attribute:
                    EditAttributeTags()
                        .environmentObject(viewModel)
                        
                case .interestTags:
                    EditInterestTagsView()
                        .environmentObject(viewModel)
                }
                
            }
            .navigationDestination(for: ProfileDestination.self) { destination in
                switch destination {
                case .wordCloud(let tags):
                    WordCloudView(skillSortedTags: tags)
                    
                case .FollowFollower(let data):
                    UserFollowFollowerView(follows: data.follows,
                                           followers: data.followers,
                                           userName: data.userName,
                                           selectedTab: data.tabNum)
                }
            }
            .navigationDestination(for: UserDatePair.self) { pairData in
                ProfileView(user: pairData.user, currentUser: viewModel.user, date: pairData.date,
                            isShowFollowButton: true, isShowDateButton: true)
            }
            .navigationDestination(for: User.self) { user in
                ProfileView(user: user, currentUser: viewModel.user, date: nil,
                            isShowFollowButton: false, isShowDateButton: true)
            }
        }
        .tint(.black)
    }// body
    
    //MARK: - Helper Functions
    
    /// 画像の上に配置するボタンアクション
    private func overlayButtonActions() -> some View {
        HStack {
            Spacer()
            
            VStack(spacing: 10) {
                NavigationLink(value: CurrentUserProfileDestination.editProfile) {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Color.black.opacity(0.8)
                                .clipShape(Circle())
                        )
                }
                
                NavigationLink(value: CurrentUserProfileDestination.editSkillTags) {
                    Image(systemName: "tag")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Color.black.opacity(0.8)
                                .clipShape(Circle())
                        )
                }
            }
        }
        .padding(.trailing, 10)
    }
    
    /// ユーザー名とプライベートアイコンを表示するビュー
    private func userNameAndPrivateIcon() -> some View {
        HStack(spacing: 4) {
            Text(viewModel.user.username)
                .font(.system(size: 35, weight: .bold, design: .default))
                .lineLimit(1)
                .padding(.bottom, 1)
            
            Image(systemName: viewModel.user.isPrivate ? "lock.fill" : "lock.open.fill")
                .font(.subheadline)
                .offset(y: 7)
        }
    }
    
    /// フォローとフォロワーのカウントビュー
    private func followFollowerCountView() -> some View {
        HStack {
            NavigationLink(value: CurrentUserProfileDestination.followFollower(FollowNavigationData(selectedTab: 0, currentUser: viewModel.user))) {
                CountView(count: followViewModel.followUsers.count, text: "フォロー")
            }
            
            NavigationLink(value: CurrentUserProfileDestination.followFollower(FollowNavigationData(selectedTab: 1, currentUser: viewModel.user))) {
                CountView(count: followerViewModel.followers.count, text: "フォロワー")
            }
        }
        .padding(.bottom, 5)
    }
    
    /// ユーザーの自己紹介文を表示するビュー
    @ViewBuilder
    private func bio() -> some View {
        if let bio = viewModel.user.bio {
            ExpandableText(
                bio,
                lineLimit: 3,
                font: .systemFont(ofSize: 14),
                ellipsis: .init(text: "…", color: .gray)
            )
            .id(bio)
            .padding(.trailing, 10)
        }
    }
    
    /// ユーザーの興味タグを表示するビュー
    @ViewBuilder
    private func interestTags() -> some View {
        if !viewModel.user.interestTags.isEmpty {
            InterestTagView(interestTags: $viewModel.user.interestTags, isShowDeleteButton: false, textFont: .footnote)
                .padding(.bottom, 5)
        }
    }
    
    /// ユーザーの技術タグを表示するビュー
    @ViewBuilder
    private func skillTags() -> some View {
        if !tagsViewModel.skillSortedTags.isEmpty {
            NavigationLink(value: CurrentUserProfileDestination.wordCloud) {
                Top3TabView(tags: tagsViewModel.skillSortedTags)
            }
        }
    }
    
    /// セクションを表示するview
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
                .padding(.leading, 10)
            
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 10)
        }
    }
    
    /// SNSリンクを表示するビュー
    private func snsLinks() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if viewModel.user.snsLinks.isEmpty {
                    NavigationLink(value: CurrentUserProfileDestination.editSNSLink) {
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
                    
                    NavigationLink(value: CurrentUserProfileDestination.editSNSLink) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                            .frame(width: 60, height: 60)
                            .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.45, green: 0.45, blue: 0.45), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 8)
                }
            } // HStack
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
        } // ScrollView
        .padding(.bottom, 10)
    }
    
    /// 記事のリンクを表示するビュー
    private func articleLinks() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                if articleLinksViewModel.openGraphData.isEmpty {
                    NavigationLink(value: CurrentUserProfileDestination.editArticle) {
                        HStack(spacing: 0) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                            Text("記事のリンクを登録しましょう")
                                .padding()
                        }
                        .foregroundColor(.mint)
                    }
                } else {
                    ForEach(articleLinksViewModel.openGraphData) { openGraphData in
                        SiteLinkButtonView(ogpData: openGraphData,
                                           _width: 200, _height: 250,
                                           showDeleteButton: false)
                            .environmentObject(articleLinksViewModel)
                    }
                    
                    NavigationLink(value: CurrentUserProfileDestination.editArticle) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                            .frame(width: 60, height: 60)
                            .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.45, green: 0.45, blue: 0.45), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .padding(.bottom, 100)
    }
    
}// view

struct FollowNavigationData: Hashable {
    let selectedTab: Int
    let currentUser: User
}
