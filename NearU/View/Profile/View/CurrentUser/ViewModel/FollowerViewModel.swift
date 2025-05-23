//
//  FollowerViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import Foundation
import Combine
import Firebase

class FollowerViewModel: ObservableObject {
    @Published var followers: [UserDatePair] = []
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    init() {
        listenForUpdates()
        setupSubscribers()

        Task {
            await loadFollowers()
        }
    }

    @MainActor
    func loadFollowers() async {
        do {
            let users = try await FollowService.fetchFollowers(receivedId: "")
            // ブロックユーザーのフィルタリング
            self.followers = BlockUserManager.shared.filterBlockedUsers(dataList: users)
        } catch {
            print("Error fetching followers: \(error)")
        }
    }

    func listenForUpdates() {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        listener = Firestore.firestore().collection("users").document(documentId).collection("followers")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for updates: \(error)")
                    return
                }
                guard let _ = querySnapshot else {
                    print("QuerySnapshot data was empty.")
                    return
                }
                Task {
                    await self.loadFollowers()
                }
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

    deinit {
        listener?.remove()
    }
}
