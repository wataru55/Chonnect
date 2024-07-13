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

    let user: User
    let GridItems : [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 2)

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ProfileHeaderView(user: user)
                    Divider() //境界線
                    //post grid view

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

                    HStack{
                        Text("Private")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 20)

                        Spacer()
                    }
                    LazyVGrid(columns: GridItems, spacing: 20, content: {
                        Button {

                        } label: {
                            Image("Instagram")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 40, height: 100)
                                .cornerRadius(12)
                                .clipped()
                        }

                        Button {

                        } label: {
                            Image("X")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 40, height: 100)
                                .cornerRadius(12)
                                .clipped()
                        }
                    })//lazyvgrid
                    .padding(.vertical, 10)

                    HStack{
                        Text("Work")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 20)

                        Spacer()
                    }
                    
                    LazyVGrid(columns: GridItems, spacing: 20, content: {
                        Button {

                        } label: {
                            Image("Discord")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 40, height: 100)
                                .cornerRadius(12)
                                .clipped()
                        }

                        Button {

                        } label: {
                            Image("Slack")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 40, height: 100)
                                .cornerRadius(12)
                                .clipped()
                        }
                    })
                    .padding(.vertical, 10)

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
    }
}

#Preview {
    CurrentUserProfileView(user: User.MOCK_USERS[2])
}
