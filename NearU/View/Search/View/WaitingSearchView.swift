//
//  AllSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.
//

import SwiftUI

struct WaitingSearchView: View {
    //MARK: - property
    let currentUser: User
    @StateObject var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack (spacing: 16) {
                    ForEach(viewModel.allUsers) { user in
                        NavigationLink(value: user) {
                            HStack {
                                CircleImageView(user: user, size: .xsmall)
                                VStack (alignment: .leading) {
                                    Text(user.username)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.primary)

                                    if let fullname = user.fullname { //fullnameがnilじゃないなら
                                        Text(fullname)
                                            .foregroundStyle(Color.primary)
                                    }

                                }//vstack
                                .font(.footnote)

                                Spacer()

                                Button(action: {
                                    Task {
                                        do {
                                            try await AuthService.shared.addUserIdToFirestore(user.id)
                                            UserDefaultsManager.shared.removeUserID(user.id)
                                            //debug
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
                                        .frame(width: 60, height: 35)
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
                                        .frame(width: 60, height: 35)
                                        .background(.gray)
                                        .cornerRadius(6)
                                })

                            }//hstack
                            .foregroundStyle(.black) //navigationlinkのデフォルトカラーを青から黒に
                            .padding(.horizontal)
                        }//navigationlink
                    }//foreach
                }//lazyvstack
                .padding(.top, 8)

            }//scrollview
            .navigationDestination(for: User.self, destination: { value in
                ProfileView(user: value, currentUser: currentUser)
            })
        }//navigationstack
    }
}

#Preview {
    WaitingSearchView(currentUser: User.MOCK_USERS[0])
}
