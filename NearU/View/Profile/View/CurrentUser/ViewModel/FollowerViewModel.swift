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
    @Published var followers: [UserHistoryRecord] = []
    private var listener: ListenerRegistration?

    init() {
        listenForUpdates()

        Task {
            await loadFollowers()
        }
    }

    func loadFollowers() async {
        do {
            let users = try await UserService.fetchFollowers(receivedId: "")

            await MainActor.run {
                self.followers = users
            }
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

    deinit {
        listener?.remove()
    }
}
