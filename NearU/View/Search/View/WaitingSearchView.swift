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
                        ForEach(viewModel.userDatePairs, id: \.0.id) { user, date in
                            NavigationLink(value: user) {
                                HStack {
                                    CircleImageView(user: user, size: .xsmall, borderColor: .clear)
                                    VStack(alignment: .leading) {
                                        Text(user.username)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.primary)

                                        if let fullname = user.fullname {
                                            Text(fullname)
                                                .foregroundStyle(Color.primary)
                                        }
                                    } // VStack
                                    .font(.footnote)

                                    Spacer()

                                    Text("\(dateFormatter.string(from: date))")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Button(action: {
                                        Task {
                                            do {
                                                try await AuthService.shared.addUserIdToFirestore(user.id)
                                                RealmManager.shared.removeData(user.id)
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
                                        RealmManager.shared.removeData(user.id)
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
            .navigationDestination(for: User.self, destination: { value in
                ProfileView(user: value, currentUser: currentUser)
            })
        } // NavigationStack
    }
}

#Preview {
    WaitingSearchView(currentUser: User.MOCK_USERS[0])
}
