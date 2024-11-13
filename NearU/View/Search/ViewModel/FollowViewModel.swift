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
    @Published var userDatePairs = [UserDatePair]()
    private var listener: ListenerRegistration?

    init() {
        listenForUpdates()

        Task {
            await fetchFollowedUsers()
        }
    }

    func fetchFollowedUsers() async {
        do {
            let users = try await UserService.fetchFollowedUsers()
            //メインスレッドで実行する必要がある
            await MainActor.run {
                self.userDatePairs = users
            }
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
                    await self.fetchFollowedUsers()
                }
            }
    }

    deinit {
        listener?.remove()
    }
}

