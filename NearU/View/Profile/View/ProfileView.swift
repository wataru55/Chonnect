//
//  ProfileView.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/04/30.
//

import SwiftUI

struct ProfileView: View {
    //MARK: - property
    let user: User //他人のユーザ情報
    let currentUser: User //自身のユーザ情報
    let GridItems : [GridItem] = Array(repeating: .init(.flexible(), spacing: 2), count: 2)

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                //header
                ProfileHeaderView(user: user)

                Divider()
                //post view

                if !user.isPrivate || currentUser.connectList.contains(user.id) && user.connectList.contains(currentUser.id){
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
                } else {
                    Spacer()
                    Text("このユーザは非公開です")
                    Spacer()
                }
            }//Vstack
        }//scrollView
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
    }//body
}//view

#Preview {
    ProfileView(user: User.MOCK_USERS[0], currentUser: User.MOCK_USERS[1])
}
