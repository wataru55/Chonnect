//
//  CurrentUserService.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/17.
//

import Foundation
import Firebase

struct CurrentUserService {
    static let subCollections = ["follows", "followers", "history",
                                     "notifications", "article", "selectedTags",
                                     "interestTags", "blocks", "blockedBy"]
    
    static func loadCurrentUser() async -> Result<User, AuthError> {
        guard let currentUid = AuthService.shared.userSession?.uid else {
            return .failure(.invalidSession)
        }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").whereField("uid", isEqualTo: currentUid).getDocuments()
            
            guard let document = snapshot.documents.first else {
                throw AuthError.userDataNotFound
            }
            
            var user = try document.data(as: User.self)
            user.id = document.documentID // idは手動で埋め込む必要がある
            
            return .success(user)
            
        } catch let error as NSError {
            print("DEBUG: ユーザーデータ取得失敗: \(error.localizedDescription)")
            switch error.code {
            case FirestoreErrorCode.unavailable.rawValue, FirestoreErrorCode.deadlineExceeded.rawValue:
                return .failure(.networkError)
                
            default:
                return .failure(.serverError)
            }
        }
    }
    
    static func updateUserName(username: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
        let docRef = Firestore.firestore().collection("users").document(documentId)
        do {
            try await docRef.updateData(["username": username])
        } catch let error as NSError {
            switch error.code {
            case FirestoreErrorCode.unavailable.rawValue, FirestoreErrorCode.deadlineExceeded.rawValue:
                throw FireStoreSaveError.networkError
                
            case FirestoreErrorCode.permissionDenied.rawValue:
                throw FireStoreSaveError.permissionDenied
                
            case FirestoreErrorCode.internal.rawValue, FirestoreErrorCode.resourceExhausted.rawValue:
                throw FireStoreSaveError.serverError
                
            default:
                throw FireStoreSaveError.unknown(underlying: error)
            }
        } catch {
            throw FireStoreSaveError.unknown(underlying: error)
        }
    }
    
    static func updateBio(bio: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
        let docRef = Firestore.firestore().collection("users").document(documentId)
        do {
            try await docRef.updateData(["bio": bio])
        } catch let error as NSError {
            switch error.code {
            case FirestoreErrorCode.unavailable.rawValue, FirestoreErrorCode.deadlineExceeded.rawValue:
                throw FireStoreSaveError.networkError
                
            case FirestoreErrorCode.permissionDenied.rawValue:
                throw FireStoreSaveError.permissionDenied
                
            case FirestoreErrorCode.internal.rawValue, FirestoreErrorCode.resourceExhausted.rawValue:
                throw FireStoreSaveError.serverError
                
            default:
                throw FireStoreSaveError.unknown(underlying: error)
            }
        } catch {
            throw FireStoreSaveError.unknown(underlying: error)
        }
    }
    
    static func updateUserProfile(username: String, bio: String, interestTags: [String]) async throws {
        guard let currentUser = AuthService.shared.currentUser else { return }
        
        var data = [String: Any]()
        
        if !username.isEmpty && currentUser.username != username {
            data["username"] = username
        }
        
        if !bio.isEmpty && currentUser.bio != bio {
            data["bio"] = bio
        }
        
        if currentUser.interestTags != interestTags {
            data["interestTags"] = interestTags
        }
        
        if !data.isEmpty {
            //Firestore Databaseのドキュメントを更新
            try await Firestore.firestore().collection("users").document(currentUser.id).updateData(data)
        }
    }
    
    // FCMトークンをFirestoreに保存するメソッド
    static func setFCMToken(fcmToken: String) async {
        guard let documentId = AuthService.shared.currentUser?.id else {
            print("ユーザーがログインしていません")
            return
        }
        
        let data: [String: Any] = ["fcmtoken": fcmToken]
        
        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(data)
            print("Document successfully updated with FCM token")
        } catch {
            print("Error updating document: \(error)")
        }
    }
    
    static func deleteInterestTags(tag: [String]) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(documentId)
        
        let data = ["interestTags": tag]
        
        try await ref.updateData(data)
    }
    
    static func deleteUser() async throws {
        guard let currentUser = AuthService.shared.currentUser else { return }
        
        await deleteSubCollection(documentId: currentUser.id)
        
        try await Firestore.firestore().collection("users").document(currentUser.id).delete()
        
        try await Auth.auth().currentUser?.delete()
    }
    
    static func deleteSubCollection(documentId: String) async {
        let ref = Firestore.firestore().collection("users").document(documentId)
    
        do {
            for collection in subCollections {
                let subCollectionRef = ref.collection(collection)
                let documents = try await subCollectionRef.getDocuments()
                
                let batch = Firestore.firestore().batch()
                for document in documents.documents {
                    batch.deleteDocument(document.reference)
                }
                try await batch.commit()
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
