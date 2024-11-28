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
    @Published var followers: [FollowerUserRowData] = []
    private var listener: ListenerRegistration?

    init() {
        listenForUpdates()

        Task {
            await loadFollowers()
        }
    }

    @MainActor
    func loadFollowers() async {
        do {
            let users = try await UserService.fetchFollowers(receivedId: "")

            var followers: [FollowerUserRowData] = []

            for user in users {
                let interestTags = try await UserService.fetchInterestTags(documentId: user.user.id)
                let addData = FollowerUserRowData(record: user, tags: interestTags)
                followers.append(addData)
            }

            self.followers = followers
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

    func updateRead(userId: String) async {
        do {
            try await UserService.updateRead(userId: userId)
            await loadFollowers()
        } catch {
            print("Error updating read status: \(error)")
        }
    }

    deinit {
        listener?.remove()
    }
}
