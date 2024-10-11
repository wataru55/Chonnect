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
//        ZStack{
//            NavigationStack {
//                ScrollView(.vertical, showsIndicators: false) {
//                    VStack (spacing: 20) {
//                        VStack (spacing: 15){
//                            // image and stats
//                            BackgroundImageView(user: user)
//                                .ignoresSafeArea(.all)
//                                .overlay(alignment: .bottomLeading) {
//                                    CircleImageView(user: user, size: .large, borderColor: .white)
//                                        .padding()
//                                }
//                           
//
//                            //name and info
//                            VStack (alignment: .leading, content: {
//                                if let fullname = user.fullname {
//                                    Text(fullname)
//                                        .font(.footnote)
//                                        .fontWeight(.bold)
//                                }
//
//                                if let bio = user.bio {
//                                    Text(bio)
//                                        .font(.footnote)
//                                }
//                            })
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.horizontal)
//
//                            //action button
//
//                            Button(action: {
//                                showEditProfile.toggle()
//                            }, label: {
//                                Text("Edit Profile")
//                                    .font(.subheadline)
//                                    .fontWeight(.semibold)
//                                    .frame(width: 360, height: 32)
//                                    .background(.white)
//                                    .cornerRadius(6)
//                                    .foregroundStyle(.black)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 6)
//                                            .stroke(.gray)
//                                    )
//                            })
//
//                        }//vstack
//                        .fullScreenCover(isPresented: $showEditProfile, content: {
//                            EditProfileView(user: user)
//                        })
//                        Divider() //境界線
//
//                        // link scroll view
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack {
//                                if user.snsLinks.isEmpty {
//                                    Text("自分のSNSのリンクを登録しましょう")
//                                        .foregroundColor(.orange)
//                                        .padding()
//                                } else {
//                                    ForEach(Array(user.snsLinks.keys), id: \.self) { key in
//                                        if let url = user.snsLinks[key] {
//                                            SNSLinkButtonView(selectedSNS: key, sns_url: url)
//                                        }
//                                    }
//                                }
//                            } // HStack
//                        } // ScrollView
//                        .padding(.leading)
//
//
//                        // add link button
//                        Button(action: {
//                            isAddingNewLink.toggle()
//                        }, label: {
//                            Image(systemName: "plus.circle")
//                                .font(.system(size: 20, weight: .semibold, design: .rounded))
//                            Text("Add Link")
//                                .font(.system(size: 24, weight: .semibold, design: .rounded))
//                        })
//                        .foregroundColor(.white)
//                        .frame(width: 360, height: 35)
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]), startPoint: .leading, endPoint: .trailing)
//                                .clipShape(Capsule())
//                        )
//                        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 8, x: 0.0, y: 4.0)
//                        .sheet(isPresented: $isAddingNewLink) {
//                            AddLinkView(isPresented: $isAddingNewLink, user: user)
//                        }
//
//                    }//Vstack
//                }//scrollView
//                .navigationTitle(user.username)
//                .navigationBarTitleDisplayMode(.inline)
//                .refreshable {
//                    Task {
//                        try await AuthService.shared.loadUserData()
//                    }
//                }
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button(action: {
//                            withAnimation(.easeInOut(duration: 0.4)) {
//                                isMenuOpen.toggle()
//                            }
//                        }, label: {
//                            Image(systemName: "line.3.horizontal")
//                                .foregroundStyle(Color.primary)
//                        })
//                    }
//                }
//            }
//            MenuView(isOpen: $isMenuOpen)
//        } //zstack
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
//                                        .foregroundStyle(.white)
                                        .padding(.bottom, 5)
                                }
                                if let bio = user.bio {
                                    Text(bio)
                                        .font(.footnote)
//                                        .foregroundStyle(.white)
                                }
                            }//VStack
                            .padding(.bottom)
                            .padding(.leading)
                        }
                        .overlay(alignment: .bottomTrailing) {
                            Button("技術"){
                                
                            }
                            .foregroundStyle(.black)
                            .padding(.bottom)
                            .padding(.trailing)
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
                    
                    // add link button
                    Button(action: {
                        isAddingNewLink.toggle()
                    }, label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        Text("Add Link")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                    })
                    .foregroundColor(.white)
                    .frame(width: 360, height: 35)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]), startPoint: .leading, endPoint: .trailing)
                            .clipShape(Capsule())
                    )
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 8, x: 0.0, y: 4.0)
                    .sheet(isPresented: $isAddingNewLink) {
                        AddLinkView(isPresented: $isAddingNewLink, user: user)
                    }
                    .padding(.bottom, 20)
                    
                    HStack(spacing: 30){
//                        Text("abstract")
                        Divider()
                            .frame(maxHeight: .infinity)
                            .background(.black)
                        
                        VStack(alignment: .trailing){
                            SiteLinkButtonView(abstract_title: "test", abstract_url: "test")
//                            if user.abstractLinks.isEmpty {
//                                Text("自分のSNSのリンクを登録しましょう")
//                                    .foregroundColor(.orange)
//                                    .padding()
//                            } else {
//                                ForEach(Array(user.abstractLinks.keys), id: \.self) { key in
//                                    if let url = user.abstractLinks[key] {
//                                        SiteLinkButtonView(abstract_title: key, abstract_url: url)
//                                    }
//                                }
//                            }
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

#Preview {
    CurrentUserProfileView(user: User.MOCK_USERS[1])
}
