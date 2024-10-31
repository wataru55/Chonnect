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
    @StateObject var abstractLinksViewModel: AbstractLinkModel

    let date: Date

    init(user: User, currentUser: User, date: Date) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user, currentUser: currentUser))
        _abstractLinksViewModel = StateObject(wrappedValue: AbstractLinkModel(userId: user.id))
      　self.date = date
    }

    var body: some View {
        ZStack{
            Color(red: 0.92, green: 0.93, blue: 0.94)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    //header
                    ProfileHeaderView(viewModel: viewModel)

                    Divider()
                    //link scroll view

                    if !viewModel.user.isPrivate || viewModel.currentUser.connectList.contains(viewModel.user.id) && viewModel.user.connectList.contains(viewModel.currentUser.id){

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack() {
                                ForEach (Array(viewModel.user.snsLinks.keys), id: \.self) { key in
                                    if let url = viewModel.user.snsLinks[key] {
                                        SNSLinkButtonView(selectedSNS: key, sns_url: url)
                                    }
                                }
                            }//hstack
                        }//scrollview
                        .padding(.leading, 5)
                        .padding(.bottom)

                    } else {
                        Spacer()
                        Text("このユーザは非公開です")
                        Spacer()
                    }
                    VStack(){
                        if viewModel.abstractLinks.isEmpty {
                            Text("リンクがありません")
                                .foregroundColor(.orange)
                                .padding()
                        } else {
                            ForEach(Array(abstractLinksViewModel.abstractLinks.keys), id: \.self) { key in
                                if let url = abstractLinksViewModel.abstractLinks[key] {
                                    SiteLinkButtonView(abstract_title: key, abstract_url: url)
                                }
                            }
                        }
                    }

                }//Vstack
                .padding(.bottom, 100)
            }//scrollView
            .background(Color(red: 0.92, green: 0.93, blue: 0.94))
            .ignoresSafeArea(.all)
            .refreshable {
                await viewModel.loadUserData()
            }
            .onAppear {
                Task {
                    await viewModel.loadUserData()
                }
                viewModel.fetchAbstractLinks()
            }
        }
        
    }//body
}//view

#Preview {
    ProfileView(user: User.MOCK_USERS[0], currentUser: User.MOCK_USERS[1], date: Date())
}
