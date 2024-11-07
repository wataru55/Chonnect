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
    @StateObject var abstractLinksViewModel: AbstractLinkModel

    @State private var isAddingNewLink = false
    @State private var showEditProfile = false
    @State var isMenuOpen = false

    let user: User
    
    init(user: User) {
        self.user = user
        _abstractLinksViewModel = StateObject(wrappedValue: AbstractLinkModel(userId: user.id))
    }

    var body: some View {
        ZStack{
            Color(red: 0.92, green: 0.93, blue: 0.94)
                .ignoresSafeArea()
            
            VStack{
                ScrollView(.vertical, showsIndicators: false){
                    VStack{
                         //image and stats
                        BackgroundImageView(user: user, height: 500, isGradient: true)
                            .overlay(alignment: .bottomLeading) {
                                VStack(alignment: .leading){
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
                            .overlay(alignment: .bottomTrailing){
                                Button(action: {
                                    showEditProfile.toggle()
                                }, label: {
                                    Text("Edit Profile")
                                        .font(.system(size: 10, weight: .semibold, design: .default))
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: 100, height: 32)
                                        .background(
                                            RoundedRectangle(cornerRadius: 30)
                                                .foregroundStyle(.ultraThinMaterial)
                                                .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
                                        )
                                })
                                .padding(.bottom)
                                .padding(.trailing)
                            }
                        
                        TagsView(tags: viewModel.selectedLanguageTags)
                        TagsView(tags: viewModel.selectedFrameworkTags)
                      
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
                        
                        Spacer()
                        
                    }//VStack
                    .padding(.bottom, 100)
                    .fullScreenCover(isPresented: $showEditProfile) {
                        EditProfileView(user: viewModel.user)
                            .environmentObject(viewModel)
                    }
                }//scrollView
                .ignoresSafeArea(.all)
            }
        }// zstack
    }// body
}// view
