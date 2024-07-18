//
//  CurrentUserProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/21.
//

import SwiftUI

struct CurrentUserProfileView: View {
    //MARK: - property
    @State private var isAddingNewLink = false
    @State private var showEditProfile = false

    let user: User

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack (spacing: 20) {
                    VStack (spacing: 15){
                        // image and stats
                        CircleImageView(user: user, size: .large)

                        //name and info
                        VStack (alignment: .leading, content: {
                            if let fullname = user.fullname {
                                Text(fullname)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                            }

                            if let bio = user.bio {
                                Text(bio)
                                    .font(.footnote)
                            }
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                        //action button

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

                    }//vstack
                    .fullScreenCover(isPresented: $showEditProfile, content: {
                        EditProfileView(user: user)
                    })
                    Divider() //境界線

                    //link scroll view
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach (Array(user.snsLinks.keys), id: \.self) { key in
                                if let url = user.snsLinks[key] {
                                    SNSLinkButtonView(selectedSNS: key, sns_url: url)
                                }
                            }
                        }//hstack
                    }//scrollview

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

                }//Vstack
            }//scrollView
            .navigationTitle(user.username)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        AuthService.shared.signout()
                    }, label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(Color.primary)
                    })
                }
            }
        }
    }// body
}// view

#Preview {
    CurrentUserProfileView(user: User.MOCK_USERS[1])
}
