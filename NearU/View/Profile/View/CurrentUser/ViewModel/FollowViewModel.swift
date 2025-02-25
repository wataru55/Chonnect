//
//  ConnectedSearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/03.
//

import Foundation
import Combine
import Firebase

class FollowViewModel: ObservableObject {
    @Published var followUsers: [FollowUserRowData] = []
    private var listener: ListenerRegistration?

    init() {
        listenForUpdates()

        Task {
            await loadFollowedUsers()
        }
    }

    @MainActor
    func loadFollowedUsers() async {
        do {
            let users = try await UserService.fetchFollowedUsers(receivedId: "")
            let filteredUsers = BlockUserManager.shared.filterBlockedUsers(dataList: users)
            
            guard !filteredUsers.isEmpty else {
                self.followUsers = []
                return
            }
            
            var followUserRowData: [FollowUserRowData] = []

            for data in filteredUsers {
                let isFollowed = await UserService.checkIsFollowed(receivedId: data.user.id)
                let interestTags = try await UserService.fetchInterestTags(documentId: data.user.id)
                let addData = FollowUserRowData(pair: data, tags: interestTags, isFollowed: isFollowed)
                followUserRowData.append(addData)
            }

            self.followUsers = followUserRowData

        } catch {
            print("Error fetching connected users: \(error)")
        }
    }

    func listenForUpdates() {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        listener = Firestore.firestore().collection("users").document(documentId).collection("follows")
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
                // ドキュメントに変更があれば fetchfollowedUsers() を実行
                Task {
                    await self.loadFollowedUsers()
                }
            }
    }

    deinit {
        listener?.remove()
    }
}

