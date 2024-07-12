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
    @Published var connectedUsers = [User]() // User型の空の配列を作成
    private var listener: ListenerRegistration?

    //MARK: - init
    init(currentUser: User) {
        self.currentUser = currentUser
        fetchConnectedUsers()
        listenForUpdates()
    }

    //MARK: - func
    func fetchConnectedUsers() {
        Task {
            do {
                let users = try await UserService.fetchConnectedUsers(withUid: currentUser.id)
                //メインスレッドで実行する必要がある
                await MainActor.run {
                    self.connectedUsers = users
                }
            } catch {
                print("Error fetching connected users: \(error)")
            }
        }
    }

    func listenForUpdates() {
        listener = Firestore.firestore().collection("users").document(currentUser.id)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for updates: \(error)")
                    return
                }
                guard let document = documentSnapshot else {
                    print("Document data was empty.")
                    return
                }
                // ドキュメントのデコードが成功したかどうかを確認
                if (try? document.data(as: User.self)) != nil {
                    self.fetchConnectedUsers() // ドキュメントの変更を検出したら再読み込み
                }
            }
    }


    deinit {
        listener?.remove()
    }
}

