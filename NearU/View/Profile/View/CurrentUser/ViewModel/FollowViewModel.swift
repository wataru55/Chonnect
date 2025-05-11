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
    private var cancellables = Set<AnyCancellable>()

    init() {
        listenForUpdates()
        setupSubscribers()

        Task {
            await loadFollowedUsers()
        }
    }

    @MainActor
    func loadFollowedUsers() async {
        do {
            let users = try await FollowService.fetchFollowedUsers(receivedId: "")
            let filteredUsers = BlockUserManager.shared.filterBlockedUsers(dataList: users)
            
            guard !filteredUsers.isEmpty else {
                self.followUsers = []
                return
            }
            
            var followUserRowData: [FollowUserRowData] = []

            for data in filteredUsers {
                let isFollowed = await FollowService.checkIsFollowed(receivedId: data.user.id)
                let addData = FollowUserRowData(pair: data, isFollowed: isFollowed)
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
    
    private func setupSubscribers() {
        BlockUserManager.shared.$blockUserIds
            .sink { [weak self] blockUserIds in
                guard let self = self else { return }
                
                // blockUserIdsに含まれるユーザーを除外
                self.followUsers = self.followUsers.filter { followUser in
                    !blockUserIds.contains(followUser.pair.userIdentifier)
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        listener?.remove()
    }
}

