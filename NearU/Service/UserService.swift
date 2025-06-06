//
//  UserService.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/05/07.
//

import Foundation
import Firebase

struct UserService {
    static func fetchUser(withUid uid: String) async -> User? {
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument() //ユーザidを使用してFirestoreDatabaseからドキュメントを取得
            return try snapshot.data(as: User.self) //snapshotからUser型にデータをデコードして値を返す
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fetchUsers(_ userIds: [String]) async throws -> [User] {
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
}

