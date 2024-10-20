//
//  UserService.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/05/07.
//

import Foundation
import Firebase

struct UserService {
    static func fetchUser(withUid uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument() //ユーザidを使用してFirestoreDatabaseからドキュメントを取得
        return try snapshot.data(as: User.self) //snapshotからUser型にデータをデコードして値を返す
    }

    static func fetchWaitingUsers(_ userIds: [String]) async throws -> [User] {
        var users = [User]()

        for userId in userIds {
            let docRef = Firestore.firestore().collection("users").document(userId)
            let document = try await docRef.getDocument()

            if let user = try? document.data(as: User.self) {
                users.append(user)
            }
        }
        return users
    }

    static func fetchConnectedUsers(withUid userId: String) async throws -> [User] {
        // First, fetch the user to get their connectList
        let user = try await fetchUser(withUid: userId)
        let connectList = user.connectList

        // Fetch the connected users
        var connectedUsers: [User] = []
        for connectedUserId in connectList {
            let connectedUser = try await fetchUser(withUid: connectedUserId)
            connectedUsers.append(connectedUser)
        }

        return connectedUsers
    }
    
    // ユーザーの選択されたタグをFirestoreに保存する関数
    static func saveUserTags(userId: String, selectedTags: [String]) async throws {
        let ref = Firestore.firestore().collection("users").document(userId).collection("selectedTags").document("tags")
        try await ref.setData(["tags": selectedTags])
    }
    
    // 選択したタグをフェッチする関数
    static func fetchUserTags(withUid id: String) async throws -> Tags {
        let snapshot = try await Firestore.firestore().collection("users").document(id).collection("selectedTags").document("tags").getDocument()
        return try snapshot.data(as: Tags.self)
    }
}
