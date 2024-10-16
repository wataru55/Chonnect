//
//  CurrentUserProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/21.
//

import SwiftUI
import Kingfisher

struct CurrentUserProfileView: View {
    //MARK: - property
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
                                TagsView(userId: user.id)
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
                    
                    Button(action: {
                        showEditProfile.toggle()
                    }, label: {
                        Text("Edit Profile")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 360, height: 32)
                            .background(.white)
                            .cornerRadius(6)
                            .foregroundStyle(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray)
                            )
                    })
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
//                        Text("abstract")
                        Divider()
                            .frame(maxHeight: .infinity)
                            .background(.black)
                        
                        VStack(alignment: .trailing){
                            SiteLinkButtonView(abstract_title: "test", abstract_url: "test")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Spacer()
                    
                }//VStack
                .padding(.bottom, 100)
                .fullScreenCover(isPresented: $showEditProfile) {
                    EditProfileView(user: user)
                }
            }//scrollView
            .ignoresSafeArea(.all)
        }
    }// body
}// view

//#Preview {
//    CurrentUserProfileView(user: User.MOCK_USERS[1])
//}
