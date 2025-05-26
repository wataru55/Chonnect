//
//  UserActions.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/22.

import Foundation
import Firebase

struct CurrentUserActions {
    static func followUser(receivedId: String, date: Date) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        let path = db.collection("users")
        
        let followerData: [String: Any] = [
            "userId": documentId,
            "date": date,
        ]
        
        let followData: [String: Any] = [
            "userId": receivedId,
            "date": date
        ]
        
        // バッチに書き込みを追加
        // 相手の followers コレクションに追加
        let followerRef = path.document(receivedId).collection("followers").document(documentId)
        batch.setData(followerData, forDocument: followerRef)
        
        // 自分の follows コレクションに追加
        let followRef = path.document(documentId).collection("follows").document(receivedId)
        batch.setData(followData, forDocument: followRef)
        
        do {
            // バッチ書き込みを実行
            try await batch.commit()
            
        } catch let error as NSError {
            throw mapFirestoreError(error)
        }
    }
    
    static func unFollowUser(receivedId: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        let path = db.collection("users")
        
        // 相手の followers から削除
        let followerRef = path.document(receivedId).collection("followers").document(documentId)
        batch.deleteDocument(followerRef)
        
        // 自分の follows から削除
        let followRef = path.document(documentId).collection("follows").document(receivedId)
        batch.deleteDocument(followRef)
        
        do {
            // バッチ書き込みを実行
            try await batch.commit()
            
        } catch let error as NSError {
            throw mapFirestoreError(error)
        }
    }
    
    static func report(to: String, content: String) async throws {
        guard let currentUserId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
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
