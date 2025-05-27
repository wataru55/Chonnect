//
//  FollowService.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/15.
//

import Foundation
import Firebase

struct FollowService {
    static func fetchFollowedUserCount(receivedId: String) async throws -> Int {
        guard let documentId = AuthService.shared.currentUser?.id else { return 0 }

        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("follows")
            .getDocuments()

        return snapshot.documents.count
    }
    
    static func fetchFollowerCount(receivedId: String) async throws -> Int {
        guard let documentId = AuthService.shared.currentUser?.id else { return 0 }

        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("followers")
            .getDocuments()

        return snapshot.documents.count
    }
    
    static func fetchFollowedUsers(receivedId: String) async throws -> [UserDatePair] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("follows").getDocuments()
        
        var followedUsers: [UserDatePair] = []
        
        for document in snapshot.documents {
            let data = try document.data(as: HistoryDataStruct.self)
            let userData = try await UserService.fetchUser(withUid: data.userId)
            let followedUser = UserDatePair(user: userData, date: data.date)
            followedUsers.append(followedUser)
        }
        return followedUsers
    }
    
    static func fetchFollowers(receivedId: String) async throws -> [UserDatePair] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("followers").getDocuments()
        
        var followers: [UserDatePair] = []
        
        for document in snapshot.documents {
            let data = try document.data(as: HistoryDataStruct.self)
            let userData = try await UserService.fetchUser(withUid: data.userId)
            let follower = UserDatePair(user: userData, date: data.date)
            followers.append(follower)
        }
        return followers
    }
    
    // フォローされているかどうかをチェックする関数
    static func checkIsFollowed(receivedId: String) async -> Bool {
        guard let documentId = AuthService.shared.currentUser?.id else { return false }
        let path = Firestore.firestore().collection("users").document(documentId).collection("followers").document(receivedId)
        
        do {
            return try await path.getDocument().exists
        } catch {
            return false
        }
    }
    
    // フォローしているかどうかをチェックする関数
    static func checkIsFollowing(receivedId: String) async -> Bool {
        guard let documentId = AuthService.shared.currentUser?.id else { return false }
        let path = Firestore.firestore().collection("users").document(documentId).collection("follows").document(receivedId)
        
        do {
            return try await path.getDocument().exists
        } catch {
            return false
        }
    }
}
