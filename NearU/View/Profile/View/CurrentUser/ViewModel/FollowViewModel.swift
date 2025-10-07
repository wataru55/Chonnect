//
//  ConnectedSearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/03.
//

import Combine
import Firebase
import Foundation

class FollowViewModel: ObservableObject {
    @Published var follows: [UserDatePair] = []
    private var followData: [HistoryDataStruct]
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    private var userProvider: UserProvider?

    init(followData: [HistoryDataStruct]) {
        self.followData = followData
        setupSubscribers()

        Task {
            self.userProvider = try? await UserProvider()
            await loadFollowedUsers()
        }
    }

    @MainActor
    func loadFollowedUsers() async {
        guard let provider = self.userProvider else {
            print("UserProviderが準備できていません。")
            return
        }

        do {
            let followUsers = try await provider.fetchUsers(with: followData)
            let userDictionary = Dictionary(uniqueKeysWithValues: followUsers.map { ($0.id, $0) })

            self.follows = followData.compactMap { data in
                if let user = userDictionary[data.userId] {
                    return UserDatePair(user: user, date: data.date)
                }
                return nil
            }

        } catch {
            print("Error fetching connected users: \(error)")
        }
    }

    @MainActor
    func reload() async {
        do {
            self.followData = try await FollowService.fetchFollowedUsers(receivedId: "")
            await loadFollowedUsers()
        } catch {
            print("Error reloading followed users: \(error)")
        }
    }

    private func setupSubscribers() {
        BlockUserManager.shared.$blockUserIds
            .sink { [weak self] blockUserIds in
                guard let self = self else { return }

                // blockUserIdsに含まれるユーザーを除外
                self.follows = self.follows.filter { followUser in
                    !blockUserIds.contains(followUser.userIdentifier)
                }
            }
            .store(in: &cancellables)
    }
}
