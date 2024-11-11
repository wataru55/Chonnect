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

    var backgroundColor: Color = Color(red: 0.92, green: 0.93, blue: 0.94) // デフォルトの背景色

    let grayColor = Color.init(white: 0.8, opacity: 1)

    let user: User

    var body: some View {
        ZStack{
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()

            VStack{
                ScrollView(.vertical, showsIndicators: false){
                    VStack{
                         //image and stats
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
//                                    Text("Edit Profile")
//                                        .font(.system(size: 10, weight: .semibold, design: .default))
//                                        .foregroundColor(.black)
//                                        .padding()
//                                        .frame(width: 100, height: 32)
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 30)
//                                                .foregroundStyle(.ultraThinMaterial)
//                                                .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
//                                        )
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 30)
//                                                .stroke(Color.black.opacity(0.5))
//                                        )
                                    Image(systemName: "pencil")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(
                                            Color.black.opacity(0.6)
                                                .clipShape(Circle())
                                        )
                                }
                                .padding(.top, 60)
                                .padding(.trailing, 20)
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
                                   ForEach(Array(addLinkViewModel.snsUrls.keys), id: \.self) { key in
                                       if let url = addLinkViewModel.snsUrls[key] {
                                           SNSLinkButtonView(selectedSNS: key, sns_url: url, isDisabled: false, isShowDeleteButton: false)
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
                                   .fullScreenCover(isPresented: $isAddingNewLink) {
                                       AddLinkView(isPresented: $isAddingNewLink)
                                           .environmentObject(addLinkViewModel)
                                   }
                               }
                           } // HStack
                        } // ScrollView
                        .padding(.leading)
                        .padding(.bottom, 10)

                        VStack(alignment: .trailing, spacing: 20) {
                            if articleLinksViewModel.openGraphData.isEmpty {
                                Text("リンクがありません")
                                    .foregroundColor(.orange)
                                    .padding()
                            } else {
                                ForEach(articleLinksViewModel.openGraphData) { openGraphData in
                                    SiteLinkButtonView(ogpData: openGraphData, showDeleteButton: false, isOpenURL: true)
                                        .environmentObject(articleLinksViewModel)
                                }
                            }
                            VStack{
                                Button(action: {
                                    showEditAbstract.toggle()
                                }, label: {
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
                                })
                            }
                            .padding(.bottom)
                            .fullScreenCover(isPresented: $showEditAbstract) {
                                EditAbstractView(isPresented: $showEditAbstract)
                                    .environmentObject(articleLinksViewModel)
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
        }// zstack
    }// body
}// view
