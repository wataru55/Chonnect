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

    static func fetchAllUsers() async throws -> [User] {
        let snapshot = try await Firestore.firestore().collection("users").getDocuments() //usersコレクションのドキュメントを全て取得
        return snapshot.documents.compactMap({ try? $0.data(as: User.self) }) //compactMapメソッドによって一つずつドキュメントを取得し，User型に変換
    }
}
