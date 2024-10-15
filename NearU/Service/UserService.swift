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
    
    static func fetchUserTags(withUid uid: String) async throws -> [String] {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("selectedTags").getDocuments()
        var tags: [String] = []
        
        for document in snapshot.documents {
            if let tagArray = document.data()["tags"] as? [String] {
                tags.append(contentsOf: tagArray)
            } else {
                print("No 'tags' field found or it's not a list in document: \(document.documentID)")
            }
        }
        
        return tags
    }
}
