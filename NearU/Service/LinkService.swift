//
//  LinkService.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/15.
//

import Foundation
import Firebase

struct LinkService {
    static func saveSNSLink(updateDict: [String: Any]) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(updateDict)
        } catch let error as NSError{
            throw mapFirestoreError(error)
        }
    }
    
    static func deleteSNSLink(serviceName: String, url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(["snsLinks.\(serviceName)": FieldValue.delete()])
        } catch let error as NSError{
            throw mapFirestoreError(error)
        }
    }
    
    static func saveArticleLink(url: String) async throws -> Article {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        let articleId = UUID().uuidString
        let createdAt = Date()
        let data: [String: Any] = [
            "id": articleId,
            "url": url,
            "createdAt": Timestamp(date: createdAt)
        ]
        do {
            try await Firestore.firestore().collection("users").document(documentId).collection("article").document(articleId).setData(data)
            return Article(id: articleId, url: url, createdAt: createdAt)
            
        } catch let error as NSError {
            throw mapFirestoreError(error)
        }
    }
    
    static func deleteArticleLink(article: Article) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        let ref = Firestore.firestore().collection("users").document(documentId).collection("article").document(article.id)
    
        do {
            try await ref.delete()
        } catch let error as NSError {
            throw mapFirestoreError(error)
        }
    }
    
    static func fetchArticleLinks(withUid userId: String) async throws -> [Article] {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("article")
                .getDocuments()
            
            var articles: [Article] = []
            
            for document in snapshot.documents {
                let data = try document.data(as: Article.self)
                articles.append(data)
            }
            
            return articles
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
