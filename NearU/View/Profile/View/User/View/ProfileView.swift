//
//  ProfileView.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/04/30.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @StateObject var supplementButtonViewModel = SupplementButtonViewModel()
    @State var isShowWordCloud: Bool = false

    let date: Date?
    let isShowFollowButton: Bool
    let isShowDateButton: Bool
    
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98)

    init(user: User, currentUser: User, date: Date?, isShowFollowButton: Bool = false, isShowDateButton: Bool) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user, currentUser: currentUser))
        self.date = date
        self.isShowFollowButton = (user.id == currentUser.id) ? false : isShowFollowButton
        self.isShowDateButton = isShowDateButton
    }

    var body: some View {
        ZStack{
            backgroundColor.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    ProfileHeaderView(viewModel: viewModel, date: date,
                                      isShowFollowButton: isShowFollowButton,
                                      isShowDateButton: isShowDateButton)
                    .environmentObject(supplementButtonViewModel)
                    
                    sectionHeader(title: "SNS")
                    
                    snsLinks()
                    
                    sectionHeader(title: "記事")
                    
                    articleLinks()
                }//scrollView
                .alert("エラー", isPresented: $viewModel.isShowAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(viewModel.errorMessage ?? "エラーが発生しました。")
                }
                .sheet(isPresented: $supplementButtonViewModel.isShowReport) {
                    ReportView(viewModel: supplementButtonViewModel, userId: viewModel.user.id)
                        .presentationDetents([.medium, .fraction(0.8)])
                }
            }
            
            ViewStateOverlayView(state: $viewModel.state)
            
        } //zstack
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .modifier(EdgeSwipe())
        .onFirstAppear {
            viewModel.loadData()
        }
    }//body
    
    //MARK: - Helper Functions
    
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
    
    /// SNSリンクを表示するview
    @ViewBuilder
    private func snsLinks() -> some View {
        if !viewModel.user.snsLinks.isEmpty && viewModel.user.isPrivate && !viewModel.isMutualFollow && !viewModel.isMyProfile {
            Text("非公開アカウントです")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
        }
        
        if viewModel.user.snsLinks.isEmpty {
            Text("リンクがありません")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding()
                .padding(.bottom, 10)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach (Array(viewModel.user.snsLinks.keys), id: \.self) { key in
                        if let url = viewModel.user.snsLinks[key] {
                            SNSLinkButtonView(selectedSNS: key, sns_url: url, isShowDeleteButton: false)
                                .disabled(viewModel.user.isPrivate && !viewModel.isMutualFollow && !viewModel.isMyProfile)
                        }
                    }
                }//hstack
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
            }//scrollview
            .padding(.bottom, 10)
        }
    }
    
    /// 記事リンクを表示するview
    @ViewBuilder
    private func articleLinks() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                if viewModel.openGraphData.isEmpty {
                    Text("記事がありません")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.openGraphData) { openGraphData in
                        SiteLinkButtonView(ogpData: openGraphData,
                                           _width: 200, _height: 250,
                                           showDeleteButton: false)
                    }
                }
            }
        }
        .padding(.bottom, 100)
    }
}//view

#Preview {
    ProfileView(user: User.MOCK_USERS[0], currentUser: User.MOCK_USERS[1], date: Date(), isShowDateButton: true)
}
