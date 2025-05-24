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
        } catch let error as NSError {
            throw mapFirestoreError(error)
        }
    }
    
    static func unFollowUser(receivedId: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        do {
            // 相手のfollowersコレクションから削除
            try await Firestore.firestore().collection("users").document(receivedId).collection("followers").document(documentId).delete()
            // 自分のfollowsコレクションから削除
            try await Firestore.firestore().collection("users").document(documentId).collection("follows").document(receivedId).delete()
            print("Followed successfully deleted")
        } catch let error as NSError {
            throw mapFirestoreError(error)
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
        
        do {
            try await reportRef.setData(data)
        } catch let error as NSError {
            throw mapFirestoreError(error)
        }
    }
    
    private static func mapFirestoreError(_ error: NSError) -> FireStoreSaveError {
        switch error.code {
        case FirestoreErrorCode.permissionDenied.rawValue:
            return .permissionDenied
        case FirestoreErrorCode.deadlineExceeded.rawValue:
            return .networkError
        case FirestoreErrorCode.unavailable.rawValue:
            return .serverError
        default:
            return .unknown(underlying: error)
        }
    }
    
}
