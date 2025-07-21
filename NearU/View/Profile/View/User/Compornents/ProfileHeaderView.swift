//
//  ProfileHeaderView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import SwiftUI

struct ProfileHeaderView: View {
    @EnvironmentObject var loadingViewModel: LoadingViewModel
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isShowCheck: Bool = false
    @Environment(\.dismiss) var dismiss

    let date: Date
    let isShowFollowButton: Bool
    let isShowDateButton: Bool

    var body: some View {
        ZStack (alignment: .top) {
            profileImage()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 50)
                
                backButton()
                
                Spacer()
                    .frame(height: 250)
                
                VStack(alignment: .leading, spacing: 6) {
                    userNameAndInfo()
                    
                    HStack {
                        followFollowerCountView()
                        
                        if isShowFollowButton {
                            Spacer()
                            
                            followButton()
                        }
                    } //HStack
                    .padding(.bottom, isShowFollowButton ? 0 : 5)
                    
                    bio()
                    
                    interestTags()
                    
                    skillTags()
                } //VStack
            } //VStack
            .padding(.leading, 10)
        } //ZStack
        .padding(.bottom, 10)
        .alert("確認", isPresented: $isShowCheck) {
            Button("戻る", role: .cancel) {
                isShowCheck.toggle()
            }
            Button("解除", role: .destructive) {
                Task {
                    await viewModel.unFollowUser()
                }
            }
        } message: {
            Text("本当にフォローを解除しますか？")
        }
    }//body
    
    //MARK: - Helper Functions
    
    private func backButton() -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Color.black.opacity(0.8)
                            .clipShape(Circle())
                    )
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    /// プロフィール画像を表示するView
    private func profileImage() -> some View {
        if let backgroundImageUrl = viewModel.user.backgroundImageUrl {
            AsyncImage(url: URL(string: backgroundImageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 500)
                    .clipped()
                    .overlay(
                        Group{
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0), location: 0.5),
                                    .init(color: Color(red: 0.96, green: 0.97, blue: 0.98).opacity(1), location: 1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    )
            } placeholder: {
                ProgressView()
            }
        } else {
            RoundedRectangle(cornerRadius: 0)
                .frame(width: UIScreen.main.bounds.width, height: 500)
                .foregroundColor(Color(.systemGray4))
                .overlay {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
        }
    }
    
    /// ユーザー名と情報を表示するView
    private func userNameAndInfo() -> some View {
        HStack(spacing: 4) {
            Text(viewModel.user.username)
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding(.bottom, 1)
                .padding(.top, 5)
                .lineLimit(1)
            
            Image(systemName: viewModel.user.isPrivate ? "lock.fill" : "lock.open.fill")
                .font(.subheadline)
                .offset(y: 7)
            
            if isShowDateButton {
                SupplementButtonView(date: date, userId: viewModel.user.id)
                    .padding(.leading, 10)
                    .offset(x: -5, y: 4)
            }
        }
        .offset(y: isShowFollowButton ? 5 : 0)
    }
    
    /// フォローとフォロワーのカウントを表示するView
    @ViewBuilder
    private func followFollowerCountView() -> some View {
        NavigationLink {
            UserFollowFollowerView(viewModel: viewModel, selectedTab: 0)
        } label: {
            CountView(count: viewModel.followCount, text: "フォロー")
        }
        
        NavigationLink {
            UserFollowFollowerView(viewModel: viewModel, selectedTab: 1)
        } label: {
            CountView(count: viewModel.followerCount, text: "フォロワー")
        }
    }
    
    /// フォローボタン
    private func followButton() -> some View {
        Group {
            if viewModel.isFollow {
                Button {
                    isShowCheck.toggle()
                } label: {
                    Text("フォロー中")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .padding()
                        .frame(height: 30)
                        .foregroundStyle(.white)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
            } else {
                Button {
                    Task {
                        await viewModel.followUser(date: date)
                    }
                } label: {
                    Text("フォロー")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(height: 30)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]), startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                }
                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 1, y: 3)
            }
        }
        .padding(.trailing, 20)
    }
    
    /// ユーザーの自己紹介を表示するView
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
    
    /// ユーザーの興味タグを表示するView
    @ViewBuilder
    private func interestTags() -> some View {
        if !viewModel.user.interestTags.isEmpty{
            InterestTagView(interestTags: viewModel.user.interestTags, isShowDeleteButton: false, textFont: .footnote)
                .padding(.bottom, 5)
        }
    }
    
    /// ユーザーのスキルタグを表示するView
    @ViewBuilder
    private func skillTags() -> some View {
        if !viewModel.skillSortedTags.isEmpty {
            NavigationLink(value: ProfileDestination.wordCloud) {
                Top3TabView(tags: viewModel.skillSortedTags)
            }
        }
    }
}//view

//#Preview {
//    ProfileHeaderView(viewModel: ProfileViewModel(user: User.MOCK_USERS[1], currentUser: User.MOCK_USERS[0]),
//                      date: Date(), isShowFollowButton: true, isShowDateButton: true)
//}
