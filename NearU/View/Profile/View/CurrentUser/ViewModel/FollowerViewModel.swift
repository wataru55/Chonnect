//
//  FollowerViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import Combine
import Firebase
import Foundation

class FollowerViewModel: ObservableObject {
    @Published var followers: [UserDatePair] = []
    private var followerData: [HistoryDataStruct]
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    private var userProvider: UserProvider?

    init(followerData: [HistoryDataStruct]) {
        self.followerData = followerData
        setupSubscribers()

        Task {
            self.userProvider = try? await UserProvider()
            await loadFollowers()
        }
    }

    @MainActor
    func loadFollowers() async {
        guard let provider = self.userProvider else {
            print("UserProviderが準備できていません。")
            return
        }

        do {
            let followerUsers = try await provider.fetchUsers(with: followerData)
            let userDictionary = Dictionary(uniqueKeysWithValues: followerUsers.map { ($0.id, $0) })

            self.followers = followerData.compactMap { data in
                if let user = userDictionary[data.userId] {
                    return UserDatePair(user: user, date: data.date)
                }
                return nil
            }
        } catch {
            print("Error fetching followers: \(error)")
        }
    }

    @MainActor
    func reload() async {
        do {
            self.followerData = try await FollowService.fetchFollowers(receivedId: "")
            await loadFollowers()
        } catch {
            print("Error reloading followers: \(error)")
        }

    }

    private func setupSubscribers() {
        BlockUserManager.shared.$blockUserIds
            .sink { [weak self] blockUserIds in
                guard let self = self else { return }

                // blockUserIdsに含まれるユーザーを除外
                self.followers = self.followers.filter { follower in
                    !blockUserIds.contains(follower.userIdentifier)
                }
            }
            .store(in: &cancellables)
    }
}
