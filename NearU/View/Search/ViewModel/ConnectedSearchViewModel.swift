//
//  ConnectedSearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/03.
//

import Foundation
import Combine
import Firebase

class ConnectedSearchViewModel: ObservableObject {
    //MARK: - property
    let currentUser: User
    @Published var userDatePairs = [UserDatePair]()
    @Published var connectedUsers = [User]() // User型の空の配列を作成
    private var listener: ListenerRegistration?

    //MARK: - init
    init(currentUser: User) {
        self.currentUser = currentUser
        listenForUpdates()

        Task {
            await fetchConnectedUsers()
        }
    }

    //MARK: - func
    func fetchConnectedUsers() async {
        do {
            let users = try await UserService.fetchConnectedUsers(documentId: currentUser.id)
            //メインスレッドで実行する必要がある
            await MainActor.run {
                self.userDatePairs = users
            }
        } catch {
            print("Error fetching connected users: \(error)")
        }
    }

    func listenForUpdates() {
        listener = Firestore.firestore().collection("users").document(currentUser.id).collection("connectList")
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
                // ドキュメントに変更があれば fetchConnectedUsers() を実行
                Task {
                    await self.fetchConnectedUsers()
                }
            }
    }

    deinit {
        listener?.remove()
    }
}

