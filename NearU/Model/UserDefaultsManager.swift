//
//  UserDefaultsManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/04.
//

import Foundation
import FirebaseFirestore

class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    private let key = "receivedUserIds"

    @Published var userIds: [String] = []

    private init() {
        // 初期化時にUserDefaultsからデータを読み込む
        userIds = UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func storeReceivedUserId(_ receivedUserId: String) {
        Task {
            // Firestore DatabaseのconnectListに同じIDがないかを確認
            let existsInFirestore = await checkIfUserIdExistsInFirestore(receivedUserId)

            // メインスレッドでUserDefaultsに保存
            await MainActor.run {
                // FirestoreとUserDefaultsの両方に存在しない場合のみ保存
                if !userIds.contains(receivedUserId) && !existsInFirestore {
                    userIds.append(receivedUserId)
                    UserDefaults.standard.set(userIds, forKey: key)
                    print("User ID \(receivedUserId) has been stored in UserDefaults.")
                } else {
                    print("User ID \(receivedUserId) already exists in UserDefaults or Firestore.")
                }
            }
        }
    }

    // FirestoreのconnectListに同じユーザーIDが存在するかチェックする関数
    private func checkIfUserIdExistsInFirestore(_ receivedUserId: String) async -> Bool {
        guard let userId = AuthService.shared.currentUser?.id else { return false }
        let document = try? await Firestore.firestore().collection("users").document(userId).getDocument()
        guard let connectList = document?.data()?["connectList"] as? [String] else { return false }
        return connectList.contains(receivedUserId)
    }

    //UserDefaultsからユーザIDを取得する関数
    func getUserIDs() -> [String] {
        return userIds
    }

    //UserDefaultsからユーザIDを削除する関数
    func removeUserID (_ userId: String) {
        if let index = userIds.firstIndex(of: userId) {
            userIds.remove(at: index)
            UserDefaults.standard.set(userIds, forKey: key)
        }
    }
}
