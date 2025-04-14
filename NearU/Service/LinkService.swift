//
//  LinkService.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/15.
//

import Foundation
import Firebase

struct LinkService {
    static func saveSNSLink(serviceName: String, url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        let data = ["snsLinks.\(serviceName)": url]
        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(data)
        } catch {
            throw error
        }
    }
    
    static func deleteSNSLink(serviceName: String, url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(["snsLinks.\(serviceName)": FieldValue.delete()])
        } catch {
            throw error
        }
    }
    
    static func seveArticleLink(url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let data = ["article_url": url]
        do {
            try await Firestore.firestore().collection("users").document(documentId).collection("article").addDocument(data: data)
        } catch {
            throw error
        }
    }
    
    static func deleteArticleLink(url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let query = Firestore.firestore().collection("users").document(documentId).collection("article").whereField("article_url", isEqualTo: url)
        
        // Firestoreから削除
        do {
            let snapshot = try await query.getDocuments()
            
            if let document = snapshot.documents.first {
                try await document.reference.delete()
            }
        } catch {
            throw error
        }
    }
    
    static func fetchArticleLinks(withUid userId: String) async throws -> [String] {
        var articleUrls: [String] = []
        
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("article")
            .getDocuments()
        
        for document in snapshot.documents {
            if let articleUrlString = document.data()["article_url"] as? String {
                articleUrls.append(articleUrlString)
            }
        }
        
        return articleUrls
    }

}
