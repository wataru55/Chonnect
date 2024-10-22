//
//  AllSearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.

import SwiftUI

struct WaitingSearchView: View {
    // MARK: - property
    @StateObject var viewModel = SearchViewModel()

    let currentUser: User

    // 日付をフォーマットするためのフォーマッター
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if viewModel.userDatePairs.isEmpty {
                        Text("すれ違ったユーザーがいません")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.userDatePairs, id: \.self) { pair in
                            NavigationLink(value: pair) {
                                HStack {
                                    CircleImageView(user: pair.user, size: .xsmall, borderColor: .clear)
                                    VStack(alignment: .leading) {
                                        Text(pair.user.username)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.primary)

                                        if let fullname = pair.user.fullname {
                                            Text(fullname)
                                                .foregroundStyle(Color.primary)
                                        }
                                    } // VStack
                                    .font(.footnote)

                                    Spacer()

                                    Text("\(dateFormatter.string(from: pair.date))")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Button(action: {
                                        Task {
                                            do {
                                                try await AuthService.shared.addUserIdToFirestore(pair.user.id, pair.date)
                                                try await UserService.followUser(receivedId: pair.user.id, date: pair.date)
                                                RealmManager.shared.removeData(pair.user.id)
                                                // デバッグ
                                                let storedUserIds = RealmManager.shared.getUserIDs()
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
                                        RealmManager.shared.removeData(pair.user.id)
                                    }, label: {
                                        Image(systemName: "hand.wave.fill")
                                            .foregroundStyle(.white)
                                            .frame(width: 60, height: 35)
                                            .background(.gray)
                                            .cornerRadius(6)
                                    })
                                } // HStack
                                .foregroundStyle(.black) // NavigationLinkのデフォルトカラーを青から黒に
                                .padding(.horizontal)
                            } // NavigationLink
                        } // ForEach
                    }
                } // LazyVStack
                .padding(.top, 8)
            } // ScrollView
            .refreshable {
                print("refresh")
            }
            .navigationDestination(for: UserDatePair.self, destination: { pair in
                ProfileView(user: pair.user, currentUser: currentUser, date: pair.date)
            })
        } // NavigationStack
    }
}

#Preview {
    WaitingSearchView(currentUser: User.MOCK_USERS[0])
}
