//
//  UserActions.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/22.

import Foundation
import Firebase

struct CurrentUserActions {
    static func followUser(receivedId: String, date: Date) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        let path = Firestore.firestore().collection("users")
        
        let followerData: [String: Any] = [
            "userId": documentId,
            "date": date,
            "isRead": false
        ]
        
        let followData: [String: Any] = [
            "userId": receivedId,
            "date": date
        ]
        
        do {
            // 相手のfollowersコレクションに保存
            try await path.document(receivedId).collection("followers").document(documentId).setData(followerData)
            // 相手のnotificationsコレクションに保存
            try await path.document(receivedId).collection("notifications").document(documentId).setData(followerData)
            // 自分のfollowsコレクションに保存
            try await path.document(documentId).collection("follows").document(receivedId).setData(followData)
            print("Followed successfully saved")
        } catch {
            print("Error saving Followed: \(error)")
            throw error
        }
    }
    
    static func deleteFollowedUser(receivedId: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        do {
            // 相手のfollowersコレクションから削除
            try await Firestore.firestore().collection("users").document(receivedId).collection("followers").document(documentId).delete()
            // 自分のfollowsコレクションから削除
            try await Firestore.firestore().collection("users").document(documentId).collection("follows").document(receivedId).delete()
            print("Followed successfully deleted")
        } catch {
            print("Error deleting Followed: \(error)")
            throw error
        }
    }
    
    static func report(to: String, content: String) async throws {
        guard let currentUserId = AuthService.shared.currentUser?.id else { return }
        
        let reportRef = Firestore.firestore().collection("reports").document("\(currentUserId)_\(to)")
            
        let data: [String: Any] = [
            "from": currentUserId,
            "to": to,
            "content": content,
            "timeStamp": Timestamp()
        ]
        
        try await reportRef.setData(data)
    }
    
    static func updateRead(userId: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(documentId).collection("followers").document(userId)
        
        do {
            try await ref.updateData(["isRead": true])
        } catch {
            throw error
        }
    }
}
