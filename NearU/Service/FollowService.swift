//
//  FollowService.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/15.
//

import Foundation
import Firebase

struct FollowService {
    static func fetchFollowedUsers(receivedId: String) async throws -> [UserDatePair] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("follows").getDocuments()
        
        var followedUsers: [UserDatePair] = []
        
        for document in snapshot.documents {
            let data = try document.data(as: NotificationData.self)
            let followedUser = try await UserService.fetchUser(withUid: data.userId)
            let userDatePair = UserDatePair(user: followedUser, date: data.date)
            followedUsers.append(userDatePair)
        }
        return followedUsers
    }
    
    static func fetchFollowers(receivedId: String) async throws -> [UserHistoryRecord] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("followers").getDocuments()
        
        var followers: [UserHistoryRecord] = []
        
        for document in snapshot.documents {
            let data = try document.data(as: HistoryDataStruct.self)
            let follower = try await UserService.fetchUser(withUid: data.userId)
            let userHistoryRecord = UserHistoryRecord(user: follower, date: data.date, isRead: data.isRead)
            followers.append(userHistoryRecord)
        }
        return followers
    }
    
    static func checkIsFollowed(receivedId: String) async -> Bool {
        guard let documentId = AuthService.shared.currentUser?.id else { return false }
        let path = Firestore.firestore().collection("users").document(documentId).collection("followers").document(receivedId)
        
        do {
            return try await path.getDocument().exists
        } catch {
            return false
        }
    }
}
