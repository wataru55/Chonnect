//
//  ProfileHeaderView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let date: Date

    var body: some View {
        VStack (spacing: 15){
            Group {
                if let backgroundImageUrl = viewModel.user.backgroundImageUrl {
                    AsyncImage(url: URL(string: backgroundImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.systemGray4))
                        .overlay {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .bottomLeading) {
                CircleImageView(user: viewModel.user, size: .large, borderColor: .white)
                    .padding()
            }
            //name and info
            VStack (alignment: .leading, content: {
                if let fullname = viewModel.user.fullname {
                    Text(fullname)
                        .font(.footnote)
                        .fontWeight(.bold)
                }

                if let bio = viewModel.user.bio {
                    Text(bio)
                        .font(.footnote)
                }
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            //action button
            if viewModel.currentUser.connectList.contains(viewModel.user.id) == true {
                Button(action: {
                    Task {
                        do {
                            try await UserService.deleteFollowedUser(receivedId: viewModel.user.id)
                            RealmManager.shared.storeData(viewModel.user.id, date: date)

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
                                RealmManager.shared.removeData(viewModel.user.id)
                                try await UserService.followUser(receivedId: viewModel.user.id, date: date)

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
                        RealmManager.shared.storeData(viewModel.user.id, date: date)
                        Task {
                            try await UserService.deleteFollowedUser(receivedId: viewModel.user.id)
                        }
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
    }//body
}//view

#Preview {
    ProfileHeaderView(viewModel: ProfileViewModel(user: User.MOCK_USERS[1], currentUser: User.MOCK_USERS[0]), date: Date())
}
