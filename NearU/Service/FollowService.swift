//
//  FollowService.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/15.
//

import Firebase
import Foundation

struct FollowService {
    static func fetchFollowedUsers(receivedId: String) async throws -> [HistoryDataStruct] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("follows").getDocuments()

        let follows = try snapshot.documents.compactMap {
            try $0.data(as: HistoryDataStruct.self)
        }

        return BlockUserManager.shared.filterBlockedUsers(dataList: follows)
    }

    static func fetchFollowers(receivedId: String) async throws -> [HistoryDataStruct] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("followers").getDocuments()

        let followers = try snapshot.documents.compactMap {
            try $0.data(as: HistoryDataStruct.self)
        }

        return BlockUserManager.shared.filterBlockedUsers(dataList: followers)
    }

    // フォローされているかどうかをチェックする関数
    static func checkIsFollowed(receivedId: String) async -> Bool {
        guard let documentId = AuthService.shared.currentUser?.id else { return false }
        let path = Firestore.firestore().collection("users").document(documentId).collection(
            "followers"
        ).document(receivedId)

        do {
            return try await path.getDocument().exists
        } catch {
            return false
        }
    }

    // フォローしているかどうかをチェックする関数
    static func checkIsFollowing(receivedId: String) async -> Bool {
        guard let documentId = AuthService.shared.currentUser?.id else { return false }
        let path = Firestore.firestore().collection("users").document(documentId).collection(
            "follows"
        ).document(receivedId)

        do {
            return try await path.getDocument().exists
        } catch {
            return false
        }
    }
}
