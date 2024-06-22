//
//  CurrentUserProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/21.
//

import SwiftUI

struct CurrentUserProfileView: View {
    //MARK: - property
    let user: User
    let GridItems : [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 2)

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ProfileHeaderView(user: user)
                    Divider() //境界線
                    //post grid view
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

                        Button {

                        } label: {
                            Image("YouTube")
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
