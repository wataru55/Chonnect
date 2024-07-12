//
//  ProfileHeaderView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import SwiftUI

struct ProfileHeaderView: View {
    let user: User
    @State private var showEditProfile = false

    var body: some View {
        VStack (spacing: 15){
            // image and stats
            HStack (spacing: 35){
                CircleImageView(user: user, size: .large)
            }

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
            if user.isCurrentUser {
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
            } else if AuthService.shared.currentUser?.connectList.contains(user.id) == true {
                Button(action: {
                    Task {
                        do {
                            UserDefaultsManager.shared.storeReceivedUserId(user.id)
                            try await AuthService.shared.removeUserIdFromFirestore(user.id)
                            // 保存されたユーザーIDをターミナルに表示
                            let storedUserIds = UserDefaultsManager.shared.getUserIDs()
                            print("Stored User IDs: \(storedUserIds)")
                        } catch {
                            // エラーハンドリング
                            print("Error: \(error)")
                        }
                    }
                }, label: {
                    Image(systemName: "hand.wave.fill")
                        .foregroundStyle(.white)
                        .frame(width: 360, height: 35)
                        .background(.gray)
                        .cornerRadius(6)
                })

            } else {
                HStack {
                    Button(action: {
                        Task {
                            do {
                                UserDefaultsManager.shared.removeUserID(user.id)
                                try await AuthService.shared.addUserIdToFirestore(user.id)
                                //degug
                                let storedUserIds = UserDefaultsManager.shared.getUserIDs()
                                print("Stored User IDs after removal: \(storedUserIds)")
                            } catch {
                                // エラーハンドリング
                                print("Error: \(error)")
                            }
                        }
                    }, label: {
                        Image(systemName: "figure.2")
                            .foregroundStyle(.white)
                            .frame(width: 180, height: 35)
                            .background(
                              LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(6)

                    })

                    Button(action: {
                        UserDefaultsManager.shared.removeUserID(user.id)

                    }, label: {
                        Image(systemName: "hand.wave.fill")
                            .foregroundStyle(.white)
                            .frame(width: 180, height: 35)
                            .background(.gray)
                            .cornerRadius(6)
                    })
                } //hstack
            }

        }//vstack
        .fullScreenCover(isPresented: $showEditProfile, content: {
            EditProfileView(user: user)
        })
    }//body
}//view

#Preview {
    ProfileHeaderView(user: User.MOCK_USERS[0])
}
