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
    @State private var isShowAlert: Bool = false
    @State private var isShowCheck: Bool = false

    let date: Date
    let isShowFollowButton: Bool

    var body: some View {
        VStack (spacing: 15){
            Group {
                if let backgroundImageUrl = viewModel.user.backgroundImageUrl {
                    AsyncImage(url: URL(string: backgroundImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
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
            .frame(width: UIScreen.main.bounds.width, height: 500)
            //name and info
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading){
                    NavigationLink {
                        TagIndexView(skillSortedTags: viewModel.skillSortedTags, interestSortedTags: viewModel.interestSortedTags)
                            .background(Color.white.opacity(0.7))
                            .ignoresSafeArea()
                    } label: {
                        Top3TabView(tags: viewModel.skillSortedTags)
                    }

                    HStack(spacing: 4) {
                        Text(viewModel.user.username)
                            .font(.system(size: 35, weight: .bold, design: .default))
                            .padding(.bottom, 1)
                            .padding(.top, 5)

                        Image(systemName: viewModel.user.isPrivate ? "lock.fill" : "lock.open.fill")
                            .font(.subheadline)
                            .offset(y: 7)
                    }

                    HStack {
                        NavigationLink(value: NavigationData(selectedTab: 0)) {
                            CountView(count: viewModel.follows.count, text: "フォロー")
                        }

                        NavigationLink(value: NavigationData(selectedTab: 1)) {
                            CountView(count: viewModel.followers.count, text: "フォロワー")
                        }

                        if isShowFollowButton {
                            Spacer()

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
                                            loadingViewModel.isLoading = true
                                            do {
                                                try await viewModel.followUser(date: date)
                                                await viewModel.checkFollow()
                                                try await viewModel.loadFollowers()
                                                loadingViewModel.isLoading = false
                                            } catch {
                                                loadingViewModel.isLoading = false
                                                isShowAlert.toggle()
                                            }
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
                    }

                    if let bio = viewModel.user.bio {
                        Text(bio)
                            .font(.footnote)
                            .frame(width: 250, alignment: .leading)
                    }

                    InterestTagView(interestTag: viewModel.interestTags, isShowDeleteButton: false)
                }//VStack
                .padding(.bottom)
                .padding(.leading)
            }
            .padding(.bottom)
        }//vstack
        .navigationDestination(for: NavigationData.self) { data in
            UserFollowFollowerView(viewModel: viewModel, selectedTab: data.selectedTab)
        }
        .alert("確認", isPresented: $isShowCheck) {
            Button("戻る", role: .cancel) {
                isShowCheck.toggle()
            }
            Button("解除", role: .destructive) {
                Task {
                    try await UserService.deleteFollowedUser(receivedId: viewModel.user.id)
                    await viewModel.checkFollow()
                    try await viewModel.loadFollowers()
                }
            }
        } message: {
            Text("本当にフォローを解除しますか？")
        }
        .alert("エラー", isPresented: $isShowAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("予期せぬエラーが発生しました\nもう一度お試しください")
        }
    }//body
}//view

struct NavigationData: Hashable {
    let selectedTab: Int
}

#Preview {
    ProfileHeaderView(viewModel: ProfileViewModel(user: User.MOCK_USERS[1], currentUser: User.MOCK_USERS[0]),
                      date: Date(), isShowFollowButton: true)
}
