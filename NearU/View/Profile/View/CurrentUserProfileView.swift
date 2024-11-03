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

    @State private var isAddingNewLink = false
    @State private var showEditProfile = false
    @State var isMenuOpen = false

    let user: User

    var body: some View {
        VStack{
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                     //image and stats
                    BackgroundImageView(user: user, height: 500, isGradient: true)
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading){
                                TagsView(tags: viewModel.selectedLanguageTags)
                                TagsView(tags: viewModel.selectedFrameworkTags)
                                if let fullname = user.fullname {
                                    Text(fullname)
                                        .font(.system(size: 25, weight: .bold, design: .default))
                                        .padding(.bottom, 5)
                                }
                                if let bio = user.bio {
                                    Text(bio)
                                        .font(.footnote)
                                        .frame(width: 250, alignment: .leading)
                                }
                            }//VStack
                            .padding(.bottom)
                            .padding(.leading)
                        }

                    HStack(spacing: 16) {
                        // edit profile button
                        Button(action: {
                            showEditProfile.toggle()
                        }, label: {
                            Text("Edit Profile")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: UIScreen.main.bounds.width / 2 - 20, height: 32)
                                .background(.white)
                                .cornerRadius(6)
                                .foregroundStyle(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.gray)
                                )
                        })
                        
                        // add link button
                        Button(action: {
                            isAddingNewLink.toggle()
                        }, label: {
                            Text("Add Link")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: UIScreen.main.bounds.width / 2 - 20, height: 32)
                                .background(.white)
                                .cornerRadius(6)
                                .foregroundStyle(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.gray)
                                )
                        })
                        .sheet(isPresented: $isAddingNewLink) {
                            AddLinkView(isPresented: $isAddingNewLink, user: viewModel.user)
                        }
                    }//HStack
                    .padding(.bottom, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                       HStack {
                           if user.snsLinks.isEmpty {
                               Text("自分のSNSのリンクを登録しましょう")
                                   .foregroundColor(.orange)
                                   .padding()
                           } else {
                               ForEach(Array(user.snsLinks.keys), id: \.self) { key in
                                   if let url = user.snsLinks[key] {
                                       SNSLinkButtonView(selectedSNS: key, sns_url: url)
                                   }
                               }
                           }
                       } // HStack
                    } // ScrollView
                    .padding(.leading)
                    .padding(.bottom, 10)
                    
                    
                    HStack(spacing: 30){
                        Divider()
                            .frame(maxHeight: .infinity)
                            .background(.black)
                        
                        VStack(alignment: .trailing, spacing: 20) {
                            if viewModel.abstractUrls.isEmpty {
                                Text("リンクがありません")
                                    .foregroundColor(.orange)
                                    .padding()
                            } else {
                                ForEach(viewModel.abstractUrls, id: \.self) { url in
                                    SiteLinkButtonView(abstract_url: url)
                                }
                            }
                        }
                        .onAppear {
                            Task {
                                await viewModel.loadAbstractLinks()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Spacer()
                    
                }//VStack
                .padding(.bottom, 100)
                .fullScreenCover(isPresented: $showEditProfile) {
                    EditProfileView()
                        .environmentObject(viewModel)
                }
            }//scrollView
            .ignoresSafeArea(.all)
        }
    }// body
}// view
