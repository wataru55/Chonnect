//
//  LinkService.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/15.
//

import Foundation
import Firebase
import OpenGraph

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
    
    static func saveArticleLink(urls: [String]) async throws -> [Article] {
        guard let documentId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }

        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(documentId).collection("article")
        let batch = db.batch()

        var articles: [Article] = []

        for url in urls {
            if !url.isEmpty {
                let articleId = UUID().uuidString
                let createdAt = Date()
                
                let data: [String: Any] = [
                    "id": articleId,
                    "url": url,
                    "createdAt": Timestamp(date: createdAt)
                ]
                
                let docRef = collectionRef.document(articleId)
                batch.setData(data, forDocument: docRef)

                articles.append(Article(id: articleId, url: url, createdAt: createdAt))
            }
        }

        do {
            try await batch.commit()
            return articles
            
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
    
    static func fetchOpenGraphData(article: Article) async -> OpenGraphData {
        guard let url = URL(string: article.url) else {
            return OpenGraphData(article: article, openGraph: nil)
        }
        
        do {
            let og = try await OpenGraph.fetch(url: url)
            return OpenGraphData(article: article, openGraph: og)
        } catch {
            return OpenGraphData(article: article, openGraph: nil)
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
