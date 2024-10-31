//
//  ProfileHeaderView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isShowAlert: Bool = false
    let date: Date

    var body: some View {
        VStack (spacing: 15){
            Group {
                if let backgroundImageUrl = viewModel.user.backgroundImageUrl {
                    AsyncImage(url: URL(string: backgroundImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .overlay(
                                Group{
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color.white.opacity(0), location: 0.5),
                                            .init(color: Color(red: 0.92, green: 0.93, blue: 0.94).opacity(1), location: 1)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            )
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    RoundedRectangle(cornerRadius: 0)
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
            .frame(width: UIScreen.main.bounds.width, height: 500)
            //name and info
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading){
                    if let fullname = viewModel.user.fullname {
                        Text(fullname)
                            .font(.system(size: 25, weight: .bold, design: .default))
                            .padding(.bottom, 5)
                    }
                    if let bio = viewModel.user.bio {
                        Text(bio)
                            .font(.footnote)
                            .frame(width: 250, alignment: .leading)
                    }
                }//VStack
                .padding(.bottom)
                .padding(.leading)
            }
            .padding(.bottom)
            
            //action button
            if viewModel.currentUser.connectList.contains(viewModel.user.id) == true {
                Button(action: {
                    Task {
                        try await UserService.deleteFollowedUser(receivedId: viewModel.user.id)
                        RealmManager.shared.storeData(viewModel.user.id, date: date)
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
                        isShowAlert.toggle()
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
                        isShowAlert.toggle()
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
        .alert("確認", isPresented: $isShowAlert) {
            Button("戻る", role: .cancel) {
                isShowAlert.toggle()
            }
            Button("解除", role: .destructive) {
                RealmManager.shared.storeData(viewModel.user.id, date: date)
                Task {
                    try await UserService.deleteFollowedUser(receivedId: viewModel.user.id)
                }
            }
        } message: {
            Text("本当にフォローを解除しますか？")
        }
    }//body
}//view

#Preview {
    ProfileHeaderView(viewModel: ProfileViewModel(user: User.MOCK_USERS[1], currentUser: User.MOCK_USERS[0]), date: Date())
}
